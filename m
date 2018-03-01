From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [net-next v3 1/2] bpf, seccomp: Add eBPF filter capabilities
Date: Thu, 1 Mar 2018 22:05:47 +0000
Message-ID: <CALCETrVwwTu0RTepfzq4jAW7d-7qKizKQdmAUhua+Md-Ljv1uQ@mail.gmail.com>
References: <20180226072702.GA27057@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180226072702.GA27057-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 26, 2018 at 7:27 AM, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org> wrote:
> This introduces the BPF_PROG_TYPE_SECCOMP bpf program type. It is meant
> to be used for seccomp filters as an alternative to cBPF filters. The
> program type has relatively limited capabilities in terms of helpers,
> but that can be extended later on.
>
> The eBPF code loading is separated from attachment of the filter, so
> a privileged user can load the filter, and pass it back to an
> unprivileged user who can attach it and use it at a later time.
>
> In order to attach the filter itself, you need to supply a flag to the
> seccomp syscall indicating that a eBPF filter is being attached, as
> opposed to a cBPF one. Verification occurs at program load time,
> so the user should only receive errors related to attachment.
> +static const struct bpf_func_proto *
> +seccomp_func_proto(enum bpf_func_id func_id)
> +{

return NULL unconditionally.  If you want different behavior, make it
a separate patch to be reviewed separately.

> +       switch (func_id) {
> +       case BPF_FUNC_get_current_uid_gid:
> +               return &bpf_get_current_uid_gid_proto;

NAK.  Doesn't work right in containers.  *Maybe* it would be okay to
have a helper that returns the uid/gid in the namespace of the filter
creator, but that's not what this does.

> +       case BPF_FUNC_ktime_get_ns:
> +               return &bpf_ktime_get_ns_proto;

NAK.  This would need a very clear use case that makes it worthwhile.
As it stands, it interferes with CRIU for no obvious good reason.

> +       case BPF_FUNC_get_prandom_u32:
> +               return &bpf_get_prandom_u32_proto;

NAK.  This helper is cryptographically insecure in that it surely
allows one user to figure out the entire random number stream of
another and, worse, it could be abused to allow one user to *control*
the stream of another user.  Read the code in bpf_user_rnd_u32.

If there is a legitimate reason to allow random number generation in
seccomp eBPF programs, it can be its own patch, and it needs, at the
very least, the properties that a filter's stream of random bytes is
unpredictable and uncontrollable by anyone else.  Realistically, this
means you need the arch_random stuff or the actual get_random_bytes()
interface.

> +       case BPF_FUNC_get_current_pid_tgid:
> +               return &bpf_get_current_pid_tgid_proto;

NAK for the same reason as get_current_uid_gid.

But Tycho: would hooking user notifiers in right here work for you?
As I see it, this would be the best justification for seccomp eBPF.

--Andy

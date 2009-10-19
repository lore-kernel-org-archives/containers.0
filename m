From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC PIDs, UIDs, and halt
Date: Mon, 19 Oct 2009 14:17:21 -0500
Message-ID: <68e6eac60910191217s5d295e54ta6b0c528dce9ce55@mail.gmail.com>
References: <68e6eac60910110930q74358967o19e3d0e88e111bd5@mail.gmail.com>
	<20091012150355.GA5783@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091012150355.GA5783-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Oct 12, 2009 at 10:03 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> Hi all,
>>
>> I'm new to LXC but have been playing around with it some.
>>
>> I ran into a few issues:
>> 1) PIDs for container processes show up on the controlling host (ps, top,
>> etc). In OpenVZ there is a way to hide them.
>
> Hmm, yes, it's basically by design, and 'fixing' it will sully the
> clean hierarchical pidns design.
>
> The easiest way to emulate that would be to have the host, during
> boot, have init split off two child pid namespaces - one for most of the
> host applications like the xserver, host's sshd, etc, and the other for
> spawning off containers. =A0Then management of pid namespaces by the
> host has to be done either from the init pid-ns, or from the pid-ns
> which spawns off containers.
<snip>
>> 3) A "kill -9 -1" run from a user in the controlling host kills all
>> processes in all containers where the owner of the process has the same =
UID
>> as the UID of the outside user. (At least the reverse is not the case).
>
> You can prevent this from happening using selinux or smack.
>
> Properly fixing this requires more work on the user namespace. =A0I am (as
> always) hoping to get time to work on that soon.
>
<snip>

Well, I more or less solved #1 and #3 for myself by launching my
gnome-session with lxc-execute.

Is there anyway to readily know the id of the PID namespace one is in?
keychain has some issues that I could correct if I could get at the
PID namespace id.

I guess expecting apps like keychain to be namespace aware would be
like expecting them to be "multiverse" aware.

I know I can pass it in through lxc-execute via an environment
variable, but I wondered if there was a more standard way.

-- Dwight

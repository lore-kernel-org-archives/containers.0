From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [net-next v3 1/2] bpf, seccomp: Add eBPF filter capabilities
Date: Mon, 5 Mar 2018 09:10:06 -0700
Message-ID: <20180305161006.ovztkslaxcskjelx@cisco>
References: <20180226072702.GA27057@ircssh-2.c.rugged-nimbus-611.internal>
	<CALCETrVwwTu0RTepfzq4jAW7d-7qKizKQdmAUhua+Md-Ljv1uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVwwTu0RTepfzq4jAW7d-7qKizKQdmAUhua+Md-Ljv1uQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Andy,

On Thu, Mar 01, 2018 at 10:05:47PM +0000, Andy Lutomirski wrote:
> But Tycho: would hooking user notifiers in right here work for you?
> As I see it, this would be the best justification for seccomp eBPF.

Sorry for the delay; Sargun had declared on irc that he was going to
implement it, so I didn't look into it. I think the basics will work,
but I haven't invested the time to look into it given the above.

Sargun, are you still planning to look at this? What's your timeline?

Cheers,

Tycho

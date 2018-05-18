From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [PATCH v2 3/4] seccomp: add a way to get a listener fd from ptrace
Date: Fri, 18 May 2018 09:10:28 -0600
Message-ID: <20180518151028.GA7699__38633.1678521403$1526656133$gmane$org@cisco>
References: <20180517151218.12850-1-tycho@tycho.ws>
	<20180517151218.12850-4-tycho@tycho.ws>
	<20180518140556.GC26297@mailbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180518140556.GC26297-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 18, 2018 at 04:05:56PM +0200, Christian Brauner wrote:
> On Thu, May 17, 2018 at 09:12:17AM -0600, Tycho Andersen wrote:
> > As an alternative to SECCOMP_FILTER_FLAG_GET_LISTENER, perhaps a ptrace()
> > version which can acquire filters is useful. There are at least two reasons
> > this is preferable, even though it uses ptrace:
> > 
> > 1. You can control tasks that aren't cooperating with you
> > 2. You can control tasks whose filters block sendmsg() and socket(); if the
> >    task installs a filter which blocks these calls, there's no way with
> >    SECCOMP_FILTER_FLAG_GET_LISTENER to get the fd out to the privileged task.
> 
> I get the problem I guess the question we need to answer is do we care
> enought to bring ptrace into this? Not really objecting, just asking. :)
> If blocking sendmsg() or socket() becomes an issue because people like
> to shoot themselves in the foot we can surely add this option later.

It doesn't seem that unreasonable to me to want to filter socket() or
sendmsg() though, so designing an API that doesn't support that from
the get-go seems like a bad idea. But that's why there are two
alternatives, so we can argue about it :)

Tycho

From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Isolated shutdown?
Date: Tue, 25 Aug 2009 11:58:00 +0200
Message-ID: <4A93B5A8.7080104@free.fr>
References: <cb541ffb0908250242g620940bi36f863a7578a0cb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cb541ffb0908250242g620940bi36f863a7578a0cb7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Scott Helvick <crazyscottie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Scott Helvick wrote:
> Hello all,
>
> I've set up a system container with a mostly-complete filesystem, built from
> scratch.  However, I'm having several minor issues, which leads me to
> believe I'm misunderstanding something about how lxc works.  For one thing,
> I find myself unable to kill processes within the container itself (process
> handling is a whole other issue)... yet when I run 'shutdown', it not only
> shuts down the container, but also the host!  Somehow I don't think this was
> a design decision. :-)
>
> Any tips would be appreciated.
>   
It is not yet supported.
You can drop PR_CAPBSET_DROP capability for your system container, that 
will avoid to poweroff your host.

I proposed to send a signal to the parent of the process 1, telling if 
the container was doing poweroff or reboot but I didn't have any response :(

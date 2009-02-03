From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: tty consideration
Date: Tue, 03 Feb 2009 18:15:05 +0100
Message-ID: <49887B99.3010101@free.fr>
References: <7B7881568CF40E4388B615CD06F87B980989EA@clara.maurer-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7B7881568CF40E4388B615CD06F87B980989EA-cHQ43lMKbBKenyD9vqZGNUEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dietmar Maurer wrote:
> Another tty problem arises from the implementation of sysv-init/upstart.
> Let me explain:
>
> sysv-init uses /dev/console (or ENV[CONSOLE]), and randomly close/reopen
> that device.
>
> upstart also uses /dev/console, and also randomly close/reopen that
> device.
>
> So far no problem, until udevd is started. udevd rewrites /dev with
> reasonable defaults.
>
> This has the side effect that your tty handling does no longer work.
>
> Ok, you will argue now that it does not make sense to start udev inside
> a container. While this is true, it is incredible difficult to avoid
> udev startup, because newer distributions have many dependencies on that
> package.
>   
Good catch !

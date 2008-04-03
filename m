From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC PATCH 0/4] Container Freezer: Reuse Suspend Freezer
Date: Thu, 3 Apr 2008 16:49:24 -0700
Message-ID: <6599ad830804031649p6bbc60f3s59fb7c25a7260505__24839.6547664472$1207266705$gmane$org@mail.gmail.com>
References: <20080403210316.397506379@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080403210316.397506379-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 3, 2008 at 2:03 PM,  <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
>    * "freezer.kill"
>
>      writing <n> will send signal number <n> to all tasks
>

My first thought (not having looked at the code yet) is that sending a
signal doesn't really have anything to do with freezing, so it
shouldn't be in the same subsystem. Maybe a separate subsystem called
"signal"?

And more than that, it's not something that requires any particular
per-process state, so there's no reason that the subsystem that
provides the "kill" functionality shouldn't be able to be mounted in
multiple hierarchies.

How about if I added support for stateless subsystems, that could
potentially be mounted in multiple hierarchies at once? They wouldn't
need an entry in the css set, since they have no state.

>  * Usage :
>
>    # mkdir /containers/freezer
>    # mount -t container -ofreezer freezer  /containers/freezer
>    # mkdir /containers/freezer/0
>    # echo $some_pid > /containers/freezer/0/tasks
>
>  to get status of the freezer subsystem :
>
>    # cat /containers/freezer/0/freezer.freeze
>    RUNNING
>
>  to freeze all tasks in the container :
>
>    # echo 1 > /containers/freezer/0/freezer.freeze
>    # cat /containers/freezer/0/freezer.freeze
>    FREEZING
>    # cat /containers/freezer/0/freezer.freeze
>    FROZEN

Could we separate this out into two files? One called "freeze" that's
a 0/1 for whether we're intending to freeze the subsystem, and one
called "frozen" that indicates whether it is frozen? And maybe a
"state" file to report the RUNNING/FREEZING/FROZEN distinction in a
human-readable way?

Paul

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: --freezer option to /bin/restart
Date: Mon, 29 Mar 2010 12:56:37 -0700
Message-ID: <20100329195637.GA26618@us.ibm.com>
References: <20100327191453.GA1533@us.ibm.com>
	<4BAF72C6.1020806@cs.columbia.edu>
	<20100328213254.GA12661@us.ibm.com>
	<4BAFD132.7040704@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BAFD132.7040704-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>>> Is there a way to specify that the restarted application belong
>>>> to a new (yet-to-be created) cgroup AND to leave the application
>>>> FROZEN after restart ? Or would we need a new command line option
>>>> and field in 'struct app_restart_args' to specify this ?
>>> This is exactly what --freezer does. Well, alsmot - except for
>>> "yet-to-be created". Do you want 'restart' to create the cgroup
>>> if it doesn't exist ?

If we restart with one of the CLONE_NEW flags like CLONE_NEWPID, a
new cgroup is automatically created right ? So, in effect, all I want
at this point is to be able to leave the restarted application in the
FROZEN state (ie specify the RESTART_FROZEN flag to sys_restart()).

>>
>> I thought that was what Suka was asking for.
>
> If he wants to add it to the 'restart' utility, then sure, with
> a proper argument.

Ok. Will add a new field to struct app_restart_args to pass the
RESTART_FROZEN flag to sys_restart(). We can then either add -F option
or allow --freezer without argument to choose this behavior.

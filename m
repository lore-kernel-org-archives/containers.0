From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Wed, 18 Mar 2009 05:28:53 -0400
Message-ID: <49C0BED5.9070203@cs.columbia.edu>
References: <20090317174359.GA10796@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090317174359.GA10796-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Catching up chronologically, I sent these to the previous version of your
patch - but it's still relevant:

https://lists.linux-foundation.org/pipermail/containers/2009-March/016307.html
https://lists.linux-foundation.org/pipermail/containers/2009-March/016308.html

Oren.

Sukadev Bhattiprolu wrote:
> Started out implementing '/proc/pid/checkpointable' which reports 0 or 1
> depending on whether a process is checkpointable atm. But realized that
> some patches that were discussed earlier are missing from Dave Hansen's
> tree.
> 
> This patchset includes those missing patches plus two new patches that
> create /proc/pid/checkpointable.
> 
>         [PATCH 1/6] Checkpoint multiple processes
>         [PATCH 2/6] Restart multiple processes
>         [PATCH 3/6] Check 'may_checkpoint()' early
>         [PATCH 4/6] Deny external checkpoint unless task is frozen
>         [PATCH 5/6] Define and use proc_pid_checkpointable()
>         [PATCH 6/6] Explain reason for task being uncheckpointable
> 

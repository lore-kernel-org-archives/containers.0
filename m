From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/5][lxc]: Link with USERCR
Date: Wed, 24 Mar 2010 21:52:37 +0100
Message-ID: <4BAA7B95.2070401@fr.ibm.com>
References: <20100319063912.GA25732@us.ibm.com> <4BA7826D.10706@fr.ibm.com>
	<20100324194744.GC20031@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100324194744.GC20031-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> Sukadev Bhattiprolu wrote:
>>> Link lxc_checkpoint, lxc_restart with USERCR[2]
>>>
>>> 3. Checkpoint/restart a simple LXC container
>>>
>>> 	$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 1000
>>>
>>> 	$ lxc-freeze --name foo
>>>
>>> 	$ lxc-checkpoint --name foo --image /root/lxc-foo.ckpt
>>>
>>> 	$ lxc-unfreeze --name foo
>> IMO, the freeze / thaw should be done in the lxc_checkpoint function code.
> 
> Well, by separating the freeze and checkpoint, we could do things like
> snapshot the filesystem or would lxc_checkpoint make an external call
> to do that ?
> 
> I will leave it as is for my next version and I am guessing it can be done
> easily later ?
>>> 	$ lxc-stop --name foo
>>>
>>> 	$ lxc-restart --name foo --image /root/lxc-foo.ckpt
>> Is the container restarted in a frozen state ?
> 
> It can be (by setting the restart_args->freezer). I will leave it in
> frozen for now. Maybe later we can add a command line option to let
> user choose whether or not to leave it frozen

The lxc_checkpoint / lxc_restart API have already the --pause option 
defined.

If you don't specify the --pause option, the checkpoint and the restart 
release the application right after finishing their job.

There is also the --kill option for the checkpoint, to kill the 
container after the checkpoint.

The lxc_checkpoint function should do:

    freeze();

    checkpoint();

    if (kill) {
        stop();
        unfreeze();
        return;
    }

    if (!pause)
        unfreeze();

    return;

The same for the restart except for the 'kill'.

The functions are already defined in lxc, it takes 5 mins to write this 
code.

Defined in lxc.h :
extern int lxc_stop(const char *name);
extern int lxc_freeze(const char *name);
extern int lxc_unfreeze(const char *name);

The lxc_checkpoint / lxc_restart functions have a 'flags' parameter with 
LXC_FLAG_PAUSE or LXC_FLAG_HALT (if set in the command line).

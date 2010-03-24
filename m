From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/5][lxc]: Link with USERCR
Date: Wed, 24 Mar 2010 15:27:59 -0400
Message-ID: <4BAA67BF.8030907@cs.columbia.edu>
References: <20100319063912.GA25732@us.ibm.com> <4BA7826D.10706@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BA7826D.10706-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org



Daniel Lezcano wrote:
> Sukadev Bhattiprolu wrote:
>> Link lxc_checkpoint, lxc_restart with USERCR[2]
>>
> 
>> 3. Checkpoint/restart a simple LXC container
>>
>>     $ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 
>> 1000
>>
>>     $ lxc-freeze --name foo
>>
>>     $ lxc-checkpoint --name foo --image /root/lxc-foo.ckpt
>>
>>     $ lxc-unfreeze --name foo
> 
> IMO, the freeze / thaw should be done in the lxc_checkpoint function code.
> 
>>     $ lxc-stop --name foo
>>
>>     $ lxc-restart --name foo --image /root/lxc-foo.ckpt
> 
> Is the container restarted in a frozen state ?
> 
> 

It could if given the proper flag to sys_restart().

Oren.

From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R][BUG] run-pthread1.sh hangs on restart
Date: Tue, 14 Jul 2009 04:34:47 -0400
Message-ID: <4A5C4327.7000200@cs.columbia.edu>
References: <20090714071507.GA337@us.ibm.com>
	<20090714072255.GA3166@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090714072255.GA3166-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


These "MIA" messages are false alarms, but once given they
break the restart. I'm working on a fix.

Oren.

Sukadev Bhattiprolu wrote:
> 
> Sorry. I was on the wrong machine which has a different kernel. Will
> re-run the test tomorrow.
> 
> 
> Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> | 
> | When I run the 'process-tree/run-pthread1.sh' test on ckpt-v17-rc1, 
> | after restart, I see following three processes running in 'ps'
> | 
> | root     21165 21114  0 00:11 ttyp0    00:00:00 ../ns_exec -cpuimP pid.pthread1 -- /home/suka/ckpt/user-cr/mktree -vd
> | root     21167 21165  0 00:11 ttyp0    00:00:00 /home/suka/ckpt/user-cr/mktree -vd
> | root     21169 21167  0 00:11 ?        00:00:00 /home/suka/ckpt/user-cr/mktree -vd
> | 
> | Attached is output of mktree (-vd) (The "Parent MIA" message is interesting)
> | 
> | Following is the kernel stack trace of the above processes - the
> | processes seem hung here even after 5 minutes.
> 

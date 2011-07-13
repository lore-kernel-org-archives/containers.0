From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: Unable to checkpoint containers
Date: Wed, 13 Jul 2011 11:39:54 +0200
Message-ID: <1310549994.11339.21.camel@bahia.local>
References: <CAC6a4axWVio4f7-v37NR+66-ZG9NHToaSGt6rT3d1jVHS0gfcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAC6a4axWVio4f7-v37NR+66-ZG9NHToaSGt6rT3d1jVHS0gfcA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Prashanth Mohan <prashmohan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2011-07-13 at 01:22 -0700, Prashanth Mohan wrote:
> Hello,
> 
> I have been following the steps in
> https://ckpt.wiki.kernel.org/index.php/Link-LXC-USERCR to get the LXC
> 0.7.1 stack to work with checkpoint and restore functionality. When I
> try to checkpoint a container, I get the following error (prmohan6
> being my container name):
> 
> lxc-checkpoint: checkpoint of prmohan6 (pid 8263) failed
> 
> lxc-checkpoint: failed to checkpoint 'prmohan6'
> 
Hi,

AFAIK, these patchsets for LXC are experimental and unmaintained...

> 
> I then tried to checkpoint a single process using the user-cr tools,
> which also failed
> $ sudo checkpoint -v 14520
> checkpoint: Device or resource busy
> (you may use 'ckptinfo -e' for more info)
> 

Did you freeze the container before checkpointing ?

> And 'ckptinfo -e' would just idle and not print out anything for me.
> Does any one know what could be the issue?
> 

'ckptinfo -e' must be fed with a checkpoint image:

cat image_file | ckptinfo -e

or

ckptinfo -r image_file

> Thanks,

-- 
Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.

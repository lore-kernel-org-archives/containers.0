From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re:
	Checkpoint / Restart)
Date: Wed, 28 Jan 2009 15:59:02 -0600
Message-ID: <20090128215902.GA5635@us.ibm.com>
References: <EF0F4DD0-96C2-47CF-A247-19002A3BD53B@uni-duesseldorf.de>
	<20090127155947.GB10039@us.ibm.com>
	<090128111035.M0106630@noir.ex.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <090128111035.M0106630-n+Fz6uxiQ6t02ytvwG4l7tBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Masahiko Takahashi <m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Masahiko Takahashi (m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org):
> Hi,
> 
> I'm now working on porting to x86_64 with help from Nauman Rafique.
> Here is the preliminary patch. If there is someone who is interested
> in x86_64 support, please join.

Cool.  Looks nice and minimal.  Thanks for doing this.

> This patch is to support x86_64 on Oren's checkpoint/restart patchset
> (v12 on December 29th). His patchset is well implemented, so the x86_64
> patch is only handling architecture specific registers. (Maybe I'm
> missing something important...)
> 
> I've tested this patch with his test suite (self.c and rstr.c) but I'm
> not confident especially in handling segment registers (%fs/%gs).
>
> This patch doesn't support external checkpointing, nor 32bit binary

Heh, and I just realized that my s390 port doesn't do self-checkpoint,
I'd only been doing external.  Oops.

> checkpoint/restart on 64bit Linux.
> 
> I would appreciate any comments and feedback.

-serge

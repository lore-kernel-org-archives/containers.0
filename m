From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-cr] cr: fs/inode.c: make sure ckpt_obj_register()
	actually runs
Date: Tue, 13 Apr 2010 16:07:37 -0700
Message-ID: <20100413230737.GG25363@count0.beaverton.ibm.com>
References: <20100413203535.GA9187@us.ibm.com>
	<20100413213217.GF25363@count0.beaverton.ibm.com>
	<20100413220931.GB13309@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100413220931.GB13309-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 13, 2010 at 05:09:31PM -0500, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > On Tue, Apr 13, 2010 at 03:35:35PM -0500, Serge E. Hallyn wrote:
> > > [ This is against Matt's code-shuffled patchset ]
> > > 
> > > So put it in its own, explicitly-called init function.
> > 
> > I did not spot the early return from inode_init(). So an alternate
> > fix is to move the #ifdef CONFIG_CHECKPOINT block up before
> > this early return:
> > 
> >         /* Hash may have been set up in inode_init_early */
> >         if (!hashdist)
> >                 return;
> > 
> > hashdist is set to HASHDIST_DEFAULT which is probably different on
> > s390 from x86-32/64. At least that would explain why this wasn't
> > spotted in my earlier testing.
> 
> Right, my x86-64 tests all passed last night too...
> 
> Anyway I still prefer it be in its own init function, but whatever

Yeah, I think there are a few advantages your approach:

1) Stays inside one #ifdef CONFIG_CHECKPOINT nicely
2) Happens at device init callback time -- we don't need to plug into early
	boot
3) Is obviously not dependent on the inode cache initialization code this way
...

> works.  You have it moved up now in your set?  When oren posts a new
> tree I'll be sure to test that.

I'll fold your patch into my set and Oren can let me know what he wants
to do.

Cheers,
	-Matt Helsley

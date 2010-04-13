From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-cr] cr: fs/inode.c: make sure ckpt_obj_register()
	actually runs
Date: Tue, 13 Apr 2010 17:09:31 -0500
Message-ID: <20100413220931.GB13309@us.ibm.com>
References: <20100413203535.GA9187@us.ibm.com>
	<20100413213217.GF25363@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100413213217.GF25363-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Tue, Apr 13, 2010 at 03:35:35PM -0500, Serge E. Hallyn wrote:
> > [ This is against Matt's code-shuffled patchset ]
> > 
> > So put it in its own, explicitly-called init function.
> 
> I did not spot the early return from inode_init(). So an alternate
> fix is to move the #ifdef CONFIG_CHECKPOINT block up before
> this early return:
> 
>         /* Hash may have been set up in inode_init_early */
>         if (!hashdist)
>                 return;
> 
> hashdist is set to HASHDIST_DEFAULT which is probably different on
> s390 from x86-32/64. At least that would explain why this wasn't
> spotted in my earlier testing.

Right, my x86-64 tests all passed last night too...

Anyway I still prefer it be in its own init function, but whatever
works.  You have it moved up now in your set?  When oren posts a new
tree I'll be sure to test that.

thanks,
-serge

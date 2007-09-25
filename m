From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/5] Add fair-user scheduler
Date: Tue, 25 Sep 2007 07:39:11 +0530
Message-ID: <20070925020911.GA26289@linux.vnet.ibm.com>
References: <20070924163326.GA10291@linux.vnet.ibm.com> <20070924164059.GE10291@linux.vnet.ibm.com> <46F84ABB.4030804@tiscali.nl>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758789AbXIYB7R@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46F84ABB.4030804@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
To: roel <12o3l@tiscali.nl>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, dmitry.adamushko@gmail.com, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, efault@gmx.de
List-Id: containers.vger.kernel.org

On Tue, Sep 25, 2007 at 01:39:39AM +0200, roel wrote:
> > +static int
> > +root_user_share_read_proc(char *page, char **start, off_t off, int count,
> > +				 int *eof, void *data)
> > +{
> > +	int len;
> > +
> > +	len = sprintf(page, "%d\n", init_task_grp_load);
> > +
> > +	return len;
> > +}
> 
> or use this oneliner:
> 
> 	return sprintf(page, "%d\n", init_task_grp_load);

Looks good. Will fix this in a follow-on.patch.

Thanks!

-- 
Regards,
vatsa

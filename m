From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 09/11] cgroups: Add a task counter subsystem
Date: Sat, 1 Oct 2011 00:03:36 +0300
Message-ID: <20110930210336.GA15366@shutemov.name>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
 <1315869091-18933-10-git-send-email-fweisbec@gmail.com>
 <20110918202710.GE28057@shutemov.name>
 <20110930125441.GB19053@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110930125441.GB19053@somewhere>
Sender: linux-kernel-owner@vger.kernel.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Containers <containers@lists.osdl.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 30, 2011 at 02:54:46PM +0200, Frederic Weisbecker wrote:
> On Sun, Sep 18, 2011 at 11:27:10PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Sep 13, 2011 at 01:11:29AM +0200, Frederic Weisbecker wrote:
> > > +static struct cftype files[] = {
> > > +	{
> > > +		.name		= "limit",
> > > +		.read_u64	= task_counter_read_u64,
> > > +		.write_u64	= task_counter_write_u64,
> > > +		.private	= RES_LIMIT,
> > > +	},
> > > +
> > > +	{
> > > +		.name		= "usage",
> > > +		.read_u64	= task_counter_read_u64,
> > 
> > It would be nice to implement .register_event/.unregister_event as well.
> 
> It adds several complications. I prefer to wait for someone requesting
> that feature before doing it.

It may be a good replacement for release_agent. Or not?

-- 
 Kirill A. Shutemov

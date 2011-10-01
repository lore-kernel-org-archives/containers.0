From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 09/11] cgroups: Add a task counter subsystem
Date: Sat, 1 Oct 2011 15:03:02 +0200
Message-ID: <20111001130259.GB3391@somewhere>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
 <1315869091-18933-10-git-send-email-fweisbec@gmail.com>
 <20110918202710.GE28057@shutemov.name>
 <20110930125441.GB19053@somewhere>
 <20110930210336.GA15366@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110930210336.GA15366@shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Containers <containers@lists.osdl.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

On Sat, Oct 01, 2011 at 12:03:36AM +0300, Kirill A. Shutemov wrote:
> On Fri, Sep 30, 2011 at 02:54:46PM +0200, Frederic Weisbecker wrote:
> > On Sun, Sep 18, 2011 at 11:27:10PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Sep 13, 2011 at 01:11:29AM +0200, Frederic Weisbecker wrote:
> > > > +static struct cftype files[] = {
> > > > +	{
> > > > +		.name		= "limit",
> > > > +		.read_u64	= task_counter_read_u64,
> > > > +		.write_u64	= task_counter_write_u64,
> > > > +		.private	= RES_LIMIT,
> > > > +	},
> > > > +
> > > > +	{
> > > > +		.name		= "usage",
> > > > +		.read_u64	= task_counter_read_u64,
> > > 
> > > It would be nice to implement .register_event/.unregister_event as well.
> > 
> > It adds several complications. I prefer to wait for someone requesting
> > that feature before doing it.
> 
> It may be a good replacement for release_agent. Or not?

Right. I just don't think it's a good idea to bring a new feature and add
maintainance work for it if it may never be used. If someone
request it for his needs, I'll be happy do implement it. We can still
do it incrementally in the future. Until then I don't see the need for it.

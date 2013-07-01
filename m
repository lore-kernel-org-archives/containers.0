From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: PROBLEM: Processes writing large files in memory-limited LXC
	container are killed by OOM
Date: Mon, 1 Jul 2013 14:02:22 -0500
Message-ID: <20130701190222.GA10367@sergelap>
References: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
	<20130701180101.GA5460@ac100> <20130701184503.GG17812@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130701184503.GG17812-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Aaron Staley <aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Johannes Weiner (hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org):
> On Mon, Jul 01, 2013 at 01:01:01PM -0500, Serge Hallyn wrote:
> > Quoting Aaron Staley (aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org):
> > > This is better explained here:
> > > http://serverfault.com/questions/516074/why-are-applications-in-a-memory-limited-lxc-container-writing-large-files-to-di
> > > (The
> > > highest-voted answer believes this to be a kernel bug.)
> > 
> > Hi,
> > 
> > in irc it has been suggested that indeed the kernel should be slowing
> > down new page creates while waiting for old page cache entries to be
> > written out to disk, rather than ooming.
> > 
> > With a 3.0.27-1-ac100 kernel, doing dd if=/dev/zero of=xxx bs=1M
> > count=100 is immediately killed.  In contrast, doing the same from a
> > 3.0.8 kernel did the right thing for me.  But I did reproduce your
> > experiment below on ec2 with the same result.
> >
> > So, cc:ing linux-mm in the hopes someone can tell us whether this
> > is expected behavior, known mis-behavior, or an unknown bug.
> 
> It's a known issue that was fixed/improved in e62e384 'memcg: prevent

Ah ok, I see the commit says:

    The solution is far from being ideal - long term solution is memcg aware
    dirty throttling - but it is meant to be a band aid until we have a real
    fix.  We are seeing this happening during nightly backups which are placed

... and ...

    The issue is more visible with slower devices for output.

I'm guessing we see it on ec2 because of slowed fs.

> OOM with too many dirty pages', included in 3.6+.

Is anyone actively working on the long term solution?

thanks,
-serge

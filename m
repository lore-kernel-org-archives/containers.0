From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Libcg-devel] Control groups and Resource Management notes
	(part II)
Date: Wed, 6 Aug 2008 09:00:34 -0400
Message-ID: <20080806130034.GA22461@redhat.com>
References: <489315B2.2080506@linux.vnet.ibm.com> <4893B415.9070906@linux.vnet.ibm.com> <20080805160709.A88B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080805133007.GC15193@redhat.com> <20080806100500.19f08444.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753916AbYHFNGU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080806100500.19f08444.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Containers <containers@lists.osdl.org>, libcg-devel <libcg-devel@lists.sourceforge.net>, linux kernel mailing list <linux-kernel@vger.kernel.org>, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Wed, Aug 06, 2008 at 10:05:00AM +0900, KAMEZAWA Hiroyuki wrote:

[..]
> > > > Vivek brought up using PAM plugins to do classifications, this suggestion was
> > > > nicely received. The decision was to do classification in user space and then
> > > > think of kernel space if it cannot be done in user space. Denis suggested that
> > > > classification is useful. In OpenVZ they classify all apache children to a
> > > > different group. Balbir asked Denis to post their classification infrastructure
> > > > as RFC.
> > > 
> > > I'm not sure about this issue.
> > > but I like PAM approach.
> > > 
> > 
> > Thanks balbir for nice summary.
> > 
> Thanks, too.
> 
> > Well, it was Rik Van Riel's idea to use PAM plugins so that processes
> > are put into right user cgroups upon login.
> > 
> > Is pam based classification alone is sufficient? I noticed couple of
> > instances which will avoid pam. For example.
> > 
> > - If one starts apache "service httpd start", then httpd threads change
> >   their uid/gid to "apache/apache". But these threads will continue to
> >   run in the cgroup belonging to root and will not go into apache cgroup.
> > 
> > - apache also offers "suexec" tool which execs a CGI script under a 
> >   different user than the user who has launched web server. I quickly
> >   grepped for source code of suexec and it does not seem to be using
> >   pam. That means CGI scripts running under some other user name will
> >   continue to run in cgroup where apache is running.
> > 
> > I am not sure how many more such corner cases are there. These cases can
> > either be covered by modification of application or using some kind of
> > wrapper around application or by writing classification daemon.
> > 
> > Do we really need classification daemon to cover such cases or wrapper
> > approach is sufficient? I remember somebody in minisummit was mentioning
> > that it should work without any apache modifications.
> > 
> 
> We can go ahead step by step. I think PAM support is the first step.
> The daemon is the second.
> 
> 1. PAM
> 2. A daemon for task placement (via netlink ?)
> 
> I think developping "a daemon for task placement" is important.
> but cannot be perfect solution for any situations.
> 
> The third step is
> 
> 3. Modify applications (in newer version of them.)
> 
> "should work without any apache modifications" is (maybe) necessary. But for 
> perfect control, it's not enough. We should support a method to modify
> applications easily in library. 
> 
> I think develpment cost for "2" is bigger than "1" and "3". If "2" is hard,
> starting from "1" and support funcs for "3" is a choice.
> If support for "3" is ready, someone may start implementation of "2" in easier
> way.
> 

Phase wise approach makes sense. I already have working patches for
following things.

1. PAM module for placement of tasks
2. Modification of init scripts and a tool "cgclassify" so that at boot up
   time "init" and other system services are moved to "admin"'s group.
3. libcgroup API so that application can use these to place forked children
   in right cgroup before doing exec.
4. A command line tool "execcg" which helps a user launch application in
   specific "cgroup".

5. A classification daemon (based on netlink as of today. Should move to
  cgroup fs based notification mechanism probably.)   

I think in phase1, we can get first 4 items merged and stablized and then
work on daemon in phase2 (if need be).

One issue with daemon was raised with respect to containers. It will
interfere with placement of container threads also and this is not
desired.

This will have to be worked out.

Thanks
Vivek

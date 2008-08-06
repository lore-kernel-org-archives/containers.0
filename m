From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Libcg-devel] Control groups and Resource Management notes
	(part II)
Date: Wed, 6 Aug 2008 10:05:00 +0900
Message-ID: <20080806100500.19f08444.kamezawa.hiroyu@jp.fujitsu.com>
References: <489315B2.2080506@linux.vnet.ibm.com>
	<4893B415.9070906@linux.vnet.ibm.com>
	<20080805160709.A88B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080805133007.GC15193@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080805133007.GC15193-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, linux kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 5 Aug 2008 09:30:07 -0400
Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Tue, Aug 05, 2008 at 04:45:30PM +0900, KOSAKI Motohiro wrote:
> > > Control group library
> > > =====================
> > > Dhaval and Balbir introduced libcgroups and the purpose of the library and the
> > > goals. Balbir described on paper what the current design looks like, it consists of
> > > 
> > > 	1. API
> > > 	2. Test framework
> > > 	3. A configuration subsystem
> > > 
> > > Dhaval discussed configuration syntax of XML versus home made. The issue of
> > > classification of tasks was brought up. The reason that we want to classify
> > > tasks is that we want them to move at fork/exec time to the correct cgroup so that
> > 
> > I don't recommend XML, because XML is tree based syntax but we want more fulexible
> > classification. then I guess XML reduce human readability.
> > 
> > 
> > > 1. They don't consume resources in the parents group
> > > 2. The movement is automatic
> > > 
> > > It was generally agreed upon that the classification should take place in user
> > > space. Eric and others suggested having a wrapper to start the application in
> > > the correct cgroup (wrapper around fork/exec). Dave suggested that one might
> > > even go the extent of hacking, such that a process is ptraced after fork/exec,
> > > moved to the correct group and resumed. Using SELinux contexts was also recommended.
> > > 
> > > Vivek brought up using PAM plugins to do classifications, this suggestion was
> > > nicely received. The decision was to do classification in user space and then
> > > think of kernel space if it cannot be done in user space. Denis suggested that
> > > classification is useful. In OpenVZ they classify all apache children to a
> > > different group. Balbir asked Denis to post their classification infrastructure
> > > as RFC.
> > 
> > I'm not sure about this issue.
> > but I like PAM approach.
> > 
> 
> Thanks balbir for nice summary.
> 
Thanks, too.

> Well, it was Rik Van Riel's idea to use PAM plugins so that processes
> are put into right user cgroups upon login.
> 
> Is pam based classification alone is sufficient? I noticed couple of
> instances which will avoid pam. For example.
> 
> - If one starts apache "service httpd start", then httpd threads change
>   their uid/gid to "apache/apache". But these threads will continue to
>   run in the cgroup belonging to root and will not go into apache cgroup.
> 
> - apache also offers "suexec" tool which execs a CGI script under a 
>   different user than the user who has launched web server. I quickly
>   grepped for source code of suexec and it does not seem to be using
>   pam. That means CGI scripts running under some other user name will
>   continue to run in cgroup where apache is running.
> 
> I am not sure how many more such corner cases are there. These cases can
> either be covered by modification of application or using some kind of
> wrapper around application or by writing classification daemon.
> 
> Do we really need classification daemon to cover such cases or wrapper
> approach is sufficient? I remember somebody in minisummit was mentioning
> that it should work without any apache modifications.
> 

We can go ahead step by step. I think PAM support is the first step.
The daemon is the second.

1. PAM
2. A daemon for task placement (via netlink ?)

I think developping "a daemon for task placement" is important.
but cannot be perfect solution for any situations.

The third step is

3. Modify applications (in newer version of them.)

"should work without any apache modifications" is (maybe) necessary. But for 
perfect control, it's not enough. We should support a method to modify
applications easily in library. 

I think develpment cost for "2" is bigger than "1" and "3". If "2" is hard,
starting from "1" and support funcs for "3" is a choice.
If support for "3" is ready, someone may start implementation of "2" in easier
way.

Thanks,
-Kame

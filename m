From: Gabor Gombas <gombasg-SuEj7oiQppWHXe+LvDLADg@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Wed, 4 Nov 2009 17:38:20 +0100
Message-ID: <20091104163820.GK16736__30646.196465432$1257353766$gmane$org@boogie.lpds.sztaki.hu>
References: <20091104063005.GC3560@balbir.in.ibm.com>
	<20091104154024.0b8f6123.kamezawa.hiroyu@jp.fujitsu.com>
	<20091104081618.GD3560@balbir.in.ibm.com>
	<1257348117.31972.4360.camel@nimitz> <4AF1A58E.1020003@redhat.com>
	<20091104160530.GI3560@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091104160530.GI3560-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 04, 2009 at 09:35:30PM +0530, Balbir Singh wrote:

> Yep, but hasn't the pollution already occured with /dev/cpuset today? 
> sysfs would require work for changes to /sys, so do we go with Kame's
> suggestion of /cgroup?

debugfs is already under /sys.

If /dev is not popular, then how about dedicating a location (say
/kernel) as a base for mounting virtual file systems? So cgroups can get
/kernel/cgroup. hugetlbfs is often mounted on /dev/hugepages but that
does not seem to be standardized as well, so it could be the second
citizen under /kernel. configfs could be moved there too. Having a
different rule for every new virtual fs does not seem to be a good
idea...

Gabor

-- 
     ---------------------------------------------------------
     MTA SZTAKI Computer and Automation Research Institute
                Hungarian Academy of Sciences
     ---------------------------------------------------------

From: Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Thu, 05 Nov 2009 13:07:28 +0100
Message-ID: <4AF2C000.3020807__35362.2464499951$1257423015$gmane$org@redhat.com>
References: <20091104063005.GC3560@balbir.in.ibm.com> <4AF1AF68.40704@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AF1AF68.40704-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/04/2009 05:44 PM, Daniel Lezcano wrote:
> Balbir Singh wrote:
>> Hi, All,
>>
>> We've been having a discussion as to what would be the right place to
>> mount the cgroup filesystem. Jan has been proactively looking into
>> this. The FHS has no recommendation since cgroup filesystem came in
>> much later.
>>
>> The options are
>>
>> 1. /dev/cgroup
>> 2. /cgroup
>> 3. Some place under /sys
>>
>> The problem with (2) is that it is quite non-standard and pollutes the
>> root directory. (3) requires some basic support to create a directory
>> for cgroup under /sys. (1) seems the most obvious choice since cpusets
>> were mounted under /dev/cpuset, but /dev is controlled by udev.
>>
>> Given the three choices or any other suggestions, is there a general
>> preference as to where we can mount it? The goal is to standardize
>> the mount point (if possible).
> Why the mount point has to be standardized ?
>

The mount point does not need to be set into stone so everybody *must* 
use it. I, as Fedora packager, just need some default place where to 
mount it, so applications which need to create/manage groups work 
without any (potentially dumb) user assistance. Of course, advanced 
admin can change the settings and move the groups anywhere, applications 
still need to parse /proc/mounts or use appropriate library like libcgroup.

Jan

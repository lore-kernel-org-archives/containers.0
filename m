From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Filesystems visibility control group
Date: Fri, 08 Feb 2008 11:13:31 +0300
Message-ID: <47AC0F2B.3070903@openvz.org>
References: <47AB1E14.1080203@openvz.org>
	<1202404169.9065.21.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1202404169.9065.21.camel-FpcvD5N4B9G9xGwK5P7XA+TW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Thu, 2008-02-07 at 18:04 +0300, Pavel Emelyanov wrote:
>> Having this proxy is the easiest way to keep the global list and
>> file_system_type structure (almost) untouched and simplify the code.
>>
>> The filesystems.list file syntax is simple: [+-]<name> without
>> a '\n' at the end. Made for 2.6.24-rc8-mm1
> 
> For what would you want this?  What kinds of filesystems would you like
> to restrict the use of in a container?

Any you want to.

E.g. ext3 with its journaling thread. Having 100 containers
with a journal in each kills the node. 
E.g. cgroupsfs if you don't want your cgroup create its 
own ones. 
E.g. NFS that can stuck on umount and block you container
on stop.

> -- Dave

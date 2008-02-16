From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7] CGroup API: More structured API for CGroups
	control files
Date: Sat, 16 Feb 2008 17:31:50 +0800
Message-ID: <47B6AD86.2060802__26181.2030840249$1203154514$gmane$org@cn.fujitsu.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080216132118.877e769b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080216132118.877e769b.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Fri, 15 Feb 2008 12:44:18 -0800
> Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
>> This set of patches makes the Control Groups API more structured and
>> self-describing.
>>
>> 1) Allows control files to be associated with data types such as
>> "u64", "string", "map", etc. These types show up in a new cgroup.api
>> file in each cgroup directory, along with a user-readable
>> string. Files that use cgroup-provided data accessors have these file
>> types inferred automatically.
>>
>> 2) Moves various files in cpusets and the memory controller from using
>> custom-written file handlers to cgroup-defined handlers
>>
>> 3) Adds the "cgroup." prefix for existing cgroup-provided control
>> files (tasks, release_agent, releasable, notify_on_release). Given
>> than we've already had 2.6.24 go out without this prefix, I guess this
>> could be a little contentious - but it seems like a good move to
>> prevent name clashes in the future. (Note that this doesn't affect
>> mounting the legacy cpuset filesystem, since the compatibility layer
>> disables all prefixes when mounted with filesystem type "cpuset"). If
>> people object too strongly, we could just make this the case for *new*
>> cgroup API files, but I think this is a case where consistency would
>> be better than compatibility - I'd be surprised if anyone has written
>> major legacy apps yet that rely on 2.6.24 cgroup control file names.
>>
> 
> 
> Hi,  I like this direction very much. thank you for your work.
> Self-describing cgroup.api file is a good idea!
> 
> One request from me is add "mode" bit to cftype for allowing
> write-only/read-only files. 
> 
> Thanks,
> -Kame
> 

I don't quite catch what you mean. Cgoup does support write-only/read-only
files. For a write-only file, just set .write and .write_uint to be NULL,
similar for a read-only file.

Do I miss something?

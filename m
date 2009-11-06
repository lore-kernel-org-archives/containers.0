From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 4/5] cgroup: pass the clone_flags to
	the	cgroup_fork_callback
Date: Fri, 06 Nov 2009 11:50:56 +0100
Message-ID: <4AF3FF90.7040100@fr.ibm.com>
References: <20091105202143.180978630@mai-009101017029.toulouse-stg.fr.ibm.com>	<20091105202810.809650098@mai-009101017029.toulouse-stg.fr.ibm.com>
	<4AF3DC81.1010603@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AF3DC81.1010603-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> On 11/05/2009 09:21 PM, Daniel Lezcano wrote:
>   
>> The fork callback is called but with just the task as parameter.
>> This one is fine to retrieve the different parameters passed to
>> the copy_process function but the clone_flags information is
>> missing, so the hook in the cgroup won't be able to use of it.
>>
>> This patch passes the clone_flags to the cgroup fork callback.
>> That will be useful for a cgroup making process and thread
>> accounting for example.
>>
>> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>> ---
>>  include/linux/cgroup.h  |    9 ++++++---
>>  kernel/cgroup.c         |    4 ++--
>>  kernel/cgroup_freezer.c |    3 ++-
>>  kernel/fork.c           |    2 +-
>>  4 files changed, 11 insertions(+), 7 deletions(-)
>>     
>
> it lacks a small change in :
>
> 	Documentation/cgroups/cgroups.txt
>
> same comment for the following patch :
>
> 	[patch 5/5] cgroup: call cgroup_exit with do_exit parameter
>   
Right, thanks Cedric.

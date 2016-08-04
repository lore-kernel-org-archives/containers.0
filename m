From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH v2 0/3] perf/tracefs: Container-aware tracing support
Date: Thu, 04 Aug 2016 13:27:49 -0500
Message-ID: <87h9b01ja2.fsf__30584.5483010218$1470336093$gmane$org@x220.int.ebiederm.org>
References: <146965470618.23765.7329786743211962695.stgit@hbathini.in.ibm.com>
	<87twf1ck95.fsf@x220.int.ebiederm.org>
	<57A355C1.4090004@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <57A355C1.4090004-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> (Aravinda Prasad's message
	of "Thu, 4 Aug 2016 20:18:33 +0530")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aravinda Prasad <aravinda-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: ananth-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, Hari Bathini <hbathini-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kernel-6AxghH7DbtA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

Aravinda Prasad <aravinda-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> On Thursday 04 August 2016 08:29 AM, Eric W. Biederman wrote:
>> Hari Bathini <hbathini-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>> 
>>> This RFC patch set supports filtering container specific events
>>> when perf tool is executed inside a container. The patches apply
>>> cleanly on v4.7.0-rc7
>>>
>>> Changes from v1:
>>> 1/3. Revived earlier approach[1] with cgroup namespace instead
>>>      of pid namespace
>>> 2/3. New patch that adds instance support for uprobe events in
>>>      tracefs filesystem
>>> 3/3. New patch that adds "newinstance" mount option for tracefs
>>>      filesystem
>>        "newinstace" ick no.
>> 
>> I see no justification anywhere why the perf cgroup is not enough for
>> this.
>
> perf cgroup is not enough for uprobes, because even with perf cgroups a
> user within a container can still list/delete uprobes registered in
> other containers.

Just to be clear, even if there is one cgroup per container?

Eric

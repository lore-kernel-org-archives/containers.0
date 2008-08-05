From: Joseph Ruscio <jruscio-ccALPSaRSA5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Mon, 4 Aug 2008 20:51:37 -0700
Message-ID: <1FA56146-7C30-4C36-982D-A50AA8BC8392@evergrid.com>
References: <20080731135703.GC22403@hawkmoon.kerlabs.com>
	<4891D5C2.8090000@cs.columbia.edu>
	<20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
	<48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4897BCE0.1080508-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


On Aug 4, 2008, at 7:37 PM, Oren Laadan wrote:

>>>> The point is that you need previous data when building an  
>>>> incremental
>>>> checkpoint, so you will read it at least. And since it was  
>>>> previously stored (in
>>> The scheme that I described above and is implemented in Zap does  
>>> not require
>>> access to previous checkpoints when building a new incremental  
>>> checkpoint.
>>> Instead, you keep some data structure in the kernel that describes  
>>> the pieces
>>> that you need to carry with you (what pages were saved, and where;  
>>> when a task
>>> exits, the data describing its mm will be discarded, of course,  
>>> and so on).
>>
>> This is because you probably decided that a mechanism in the kernel  
>> that saves
>> storage space was not interesting if it does not improve speed. As a
>> consequence you need to keep metadata in kernel memory in order to do
>> incremental checkpoint. Maybe saving storage space without  
>> considering
>> speed could equally be done from userspace with sort of checkpoint  
>> diff
>> tools that would create an incremental checkpoint 2' from two full
>> checkpoints 1 and 2.
>
> Good point. In fact, the meta data is not only kept in memory, but  
> also saved
> with each incremental checkpoint (well, its version at checkpoint  
> time), so
> that restart would know where to find older data. So it is already  
> transfered
> to user space; we may as well provide the option to keep it only in  
> user space.

As somewhat of a tangent to this discussion, I've been giving some  
thought to the general strategy we talked about during the summit. The  
checkpointing solution we built at Evergrid sits completely in  
userspace and is soley focused on checkpointing parallel codes (e.g.  
MPI). That approach required us to virtualize a whole slew of  
resources (e.g. PIDs) that will be far better supported in the kernel  
through this effort. On the other hand, there isn't anything inherent  
to checkpointing the memory in a process that requires it to be in a  
kernel. During a restart, you can map and load the memory from the  
checkpoint file in userspace as easily as in the kernel. Since the  
cost of checkpointing HPC codes is fairly dominated by checkpointing  
their large memory footprints, memory checkpointing is an area of  
ongoing research with many different solutions.

It might be desirable for the checkpointing implementation to be  
modular enough that a userspace application or library could select to  
handle certain resources on their own. Memory is the primary one that  
comes to mind.

-joe

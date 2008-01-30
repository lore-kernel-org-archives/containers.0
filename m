From: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 09/15] (RFC) IPC: new kernel API to change
 an ID
Date: Wed, 30 Jan 2008 10:52:14 +0100
Message-ID: <47A048CE.40106@bull.net>
References: <20080129160229.612172683@bull.net>
	<20080129162000.454857358@bull.net>
	<20080129210656.GB1990@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080129210656.GB1990-QDJVlCTZ4KWTKS93B3g+7KFoa47nwP16@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Alexey Dobriyan wrote:
> On Tue, Jan 29, 2008 at 05:02:38PM +0100, pierre.peiffer-6ktuUTfB/bM@public.gmane.org wrote:
>> This patch provides three new API to change the ID of an existing
>> System V IPCs.
>>
>> These APIs are:
>> 	long msg_chid(struct ipc_namespace *ns, int id, int newid);
>> 	long sem_chid(struct ipc_namespace *ns, int id, int newid);
>> 	long shm_chid(struct ipc_namespace *ns, int id, int newid);
>>
>> They return 0 or an error code in case of failure.
>>
>> They may be useful for setting a specific ID for an IPC when preparing
>> a restart operation.
>>
>> To be successful, the following rules must be respected:
>> - the IPC exists (of course...)
>> - the new ID must satisfy the ID computation rule.
>> - the entry in the idr corresponding to the new ID must be free.
> 
>>  ipc/util.c          |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  ipc/util.h          |    1 +
>>  8 files changed, 197 insertions(+)
> 
> For the record, OpenVZ uses "create with predefined ID" method which
> leads to less code. For example, change at the end is all we want from
> ipc/util.c .
> 

Yes, indeed, I saw that. The idea here is, at the end, to propose a more
"userspace oriented" solution.
As we can't use msgget(), etc, API to specify an ID, I think we can at least
change it afterwards

> Also, if ids were A and B at the moment of checkpoint, and during
> restart they became B and A you'll get collision in both ways which you
> techically can avoid by classic "tmp = A, A = B, B = tmp"

In the general case, yes, you're right.
In the case of the checkpoint/restart, this is not necessarily a problem, as we
will probably restart an application in an empty "container"/"namespace"; Thus
we can create all needed IPCs in an empty IPC namespace like this:
1. create first IPC
2. change its ID
3. create the second IPC
4. change its ID
5. etc..

But yes, I agree that if we can directly create an IPC with the right ID, it
would be better; may be with an IPC_CREATE command or something like that if the
direction is to do that from userspace.

-- 
Pierre Peiffer

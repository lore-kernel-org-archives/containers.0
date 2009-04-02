From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 1/7] ipc: allow allocation of an ipc	object
	with desired identifier
Date: Thu, 02 Apr 2009 18:26:57 -0400
Message-ID: <49D53BB1.7000501@cs.columbia.edu>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
	<1238477552-17083-2-git-send-email-orenl@cs.columbia.edu>
	<20090402172233.GB9984@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090402172233.GB9984-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> -int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
>> +int
>> +ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int size, int req_id)
>>  {
>>  	uid_t euid;
>>  	gid_t egid;
>> +	int lid = 0;
>>  	int id, err;
>>
>>  	if (size > IPCMNI)
>> @@ -268,28 +270,41 @@ int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
>>  	if (ids->in_use >= size)
>>  		return -ENOSPC;
>>
>> +	if (req_id >= 0)
>> +		lid = ipcid_to_idx(req_id);
>> +
>>  	spin_lock_init(&new->lock);
>>  	new->deleted = 0;
>>  	rcu_read_lock();
>>  	spin_lock(&new->lock);
>>
>> -	err = idr_get_new(&ids->ipcs_idr, new, &id);
>> +	err = idr_get_new_above(&ids->ipcs_idr, new, lid, &id);
>>  	if (err) {
>>  		spin_unlock(&new->lock);
>>  		rcu_read_unlock();
>>  		return err;
>>  	}
>>
>> +	if (req_id >= 0) {
>> +		if (id != lid) {
>> +			idr_remove(&ids->ipcs_idr, id);
>> +			spin_unlock(&new->lock);
>> +			rcu_read_unlock();
>> +			return -EBUSY;
>> +		}
>> +		new->seq = req_id / SEQ_MULTIPLIER;
> 
> Should this be
> 	
> 	new->seq = req_id % ids->seq_max;
> 
> ?

This is how the user-visible IPC id is constructed:

	static inline int ipc_buildid(int id, int seq)
	{
	        return SEQ_MULTIPLIER * seq + id;
	}

and I want to get the original 'seq' ....  (the 'id' in this function is
an in-kernel identifier)

> 
>> +	} else {
>> +		new->seq = ids->seq++;
>> +		if (ids->seq > ids->seq_max)
>> +			ids->seq = 0;
>> +	}
>> +
>>  	ids->in_use++;
>>
>>  	current_euid_egid(&euid, &egid);
>>  	new->cuid = new->uid = euid;
>>  	new->gid = new->cgid = egid;
>>
>> -	new->seq = ids->seq++;
>> -	if(ids->seq > ids->seq_max)
>> -		ids->seq = 0;
>> -
> 

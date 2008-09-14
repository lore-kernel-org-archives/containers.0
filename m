From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v5][PATCH 8/8] Dump open file descriptors
Date: Sun, 14 Sep 2008 11:40:25 -0400
Message-ID: <48CD3069.7080200__42410.2591736757$1221407304$gmane$org@cs.columbia.edu>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-9-git-send-email-orenl@cs.columbia.edu>
	<20080914095106.GA6300@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080914095106.GA6300-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel@v
List-Id: containers.vger.kernel.org



Bastian Blank wrote:
> On Sat, Sep 13, 2008 at 07:06:06PM -0400, Oren Laadan wrote:
>> +int cr_scan_fds(struct files_struct *files, int **fdtable)
>> +{
>> +	struct fdtable *fdt;
>> +	int *fds;
>> +	int i, n, tot;
>> +
>> +	n = 0;
>> +	tot = CR_DEFAULT_FDTABLE;
> 
> Why not?
> | int i;
> | int n = 0;
> | int tot = CR_DEFAULT_FDTABLE;
> 
> IHMO easier readable.

Ok.

> 
>> +	spin_lock(&files->file_lock);
>> +	fdt = files_fdtable(files);
>> +	for (i = 0; i < fdt->max_fds; i++) {
> 
> The process is suspended at this state?

Yes, the assumption is that the process is frozen (or that we checkpoint
ourselves).

With this assumption, it is possible to (a) leave out RCU locking, and also
(b) continue after the krealloc() from where we left off. Also, it means that
(c) the contents of our 'fds' array remain valid by the time the caller makes
use of it.

This certainly deserves a comment in the code, will add.

If the assumption doesn't hold, then I'll have to add the RCU locking. Cases
(b) and (c) are already safe because the caller(s) use fcheck_files() to
access the file-descriptors collected in the array.

While in my mind a task should never be unfrozen while being checkpointed, in
reality future code may allow it e.g. if a OOM kicks in a kills it. So I tend
to add the RCU lock for safety. It can always be optimized out later.

> 
>> +		if (n == tot) {
>> +			/*
>> +			 * fcheck_files() is safe with drop/re-acquire
>> +			 * of the lock, because it tests:  fd < max_fds
>> +			 */
>> +			spin_unlock(&files->file_lock);
>> +			tot *= 2;
>> +			if (tot < 0) {		/* overflow ? */
> 
> _NO_. tot is signed, this does not have documented overflow behaviour.
> You need to restrict this to a sane number.

Ok. (btw, krealloc() will fail much earlier anyway).

> 
>> +				kfree(fds);
>> +				return -EMFILE;
>> +			}
>> +			fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
>> +			if (!fds)
> 
> krealloc does not free the memory on error, so this is a leak.

Ok.

Thanks,

Oren.

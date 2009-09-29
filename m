From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] Add checkpoint/restart support for epoll files.
Date: Tue, 29 Sep 2009 19:31:15 -0400
Message-ID: <4AC298C3.2030203@librato.com>
References: <1254164482-2193-2-git-send-email-matthltc@us.ibm.com>
	<4AC29086.8080407@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AC29086.8080407-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Oren Laadan wrote:
> 
> Matt Helsley wrote:
>> Save/restore epoll items during checkpoint/restart respectively.
>> kmalloc failures should be dealt with more kindly than just error-out
>> because epoll is made to poll many thousands of file descriptors.
>> Subsequent patches will change epoll c/r to "chunk" its output/input
>> respectively.
> 
> [...]
> 
>>  
>> @@ -311,9 +313,11 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
>>  	}
>>  
>>  	ret = deferqueue_run(ctx->files_deferq);
>> -	ckpt_debug("files_deferq ran %d entries\n", ret);
>> -	if (ret > 0)
>> +	if (ret > 0) {
>> +		ckpt_debug("file checkpoint deferred %d work items\n", ret);
>>  		ret = 0;
>> +	}
>> +
> 
> With your permission, I'll do this hunk as a separate patch (and
> the restore counterpart too). So you can remove from your patch.

I take that back. I prefer the previous debug, that give info
whether the call succeeded or not...

Oren.

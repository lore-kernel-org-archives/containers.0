From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v3 4/4] parse options in the vfs level
Date: Tue, 23 Aug 2011 23:19:26 -0300
Message-ID: <4E545FAE.5040008__34802.1016376608$1314152434$gmane$org@parallels.com>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-5-git-send-email-glommer@parallels.com>
	<20110815070932.GF26978@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110815070932.GF26978@dastard>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/15/2011 04:09 AM, Dave Chinner wrote:
> On Sun, Aug 14, 2011 at 07:13:52PM +0400, Glauber Costa wrote:
>> This patch introduces a simple generic vfs option parser.
>> Right now, the only option we have is to limit the size of the dcache.
>>
>> So any user that wants to have a dcache entries limit, can specify:
>>
>>    mount -o whatever_options,vfs_dcache_size=XXX<dev>  <mntpoint>
>>
>> It is supposed to work well with remounts, allowing it to change
>> multiple over the course of the filesystem's lifecycle.
>>
>> I find mount a natural interface for handling filesystem options,
>> so that's what I've choosen. Feel free to yell at it at will if
>> you disagree.
>
> It's already been noted by both myself and Al that there is not a
> 1:1 mapping between mount point and superblocks....

I had skipped that one in my pending patches.

Well, it's already been noted by me as well. And by anybody.
The problem, however, is not new. Filesystems exports fs-specific
options that operate on the superblock as well. And we've been living 
alright with them.

>> @@ -2350,6 +2449,12 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
>>   	else
>>   		retval = do_new_mount(&path, type_page, flags, mnt_flags,
>>   				      dev_name, data_page);
>> +
>> +	/* bind mounts get to respect their parents decision */
>> +	if (!retval&&  !(flags&  MS_BIND))
>> +		vfs_set_dcache_size(path.mnt->mnt_sb,
>> +				    vfs_options.vfs_dcache_size);
>> +			
>
> And I'm not sure that silently ignoring it in certain cases
> is the best way around that problem.

It is not "in certain cases". It is : 1) When bind mounting, and 2) When 
an error occurs. Pretty well-defined.

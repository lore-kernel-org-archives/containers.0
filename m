From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v3 4/4] parse options in the vfs level
Date: Sun, 14 Aug 2011 17:03:52 -0700
Message-ID: <4E486268.60205__14953.965371433$1313366770$gmane$org@parallels.com>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-5-git-send-email-glommer@parallels.com>
	<20110814153930.GA3996@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110814153930.GA3996@albatros>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/14/2011 08:39 AM, Vasiliy Kulikov wrote:
> Hi Glauber,
>
> On Sun, Aug 14, 2011 at 19:13 +0400, Glauber Costa wrote:
>> +/**
>> + * Generic option parsing for the VFS.
>> + *
>> + * Since most of the filesystems already do their own option parsing, and with
>> + * very few code shared between them, this function strips out any options that
>> + * we succeed in parsing ourselves. Passing them forward would just give the
>> + * underlying fs an option it does not expect, leading it to fail.
>> + *
>> + * We don't yet have a pointer to the super block as well, since this is
>> + * pre-mount. We accumulate in struct vfs_options whatever data we collected,
>> + * and act on it later.
>> + */
>> +static int vfs_parse_options(char *options, struct vfs_options *ops)
>> +{
>> +	substring_t args[MAX_OPT_ARGS];
>> +	int option;
>> +	char *p;
>> +	char *opt;
>> +	char *start = NULL;
>> +	int ret;
>> +	
>> +	if (!options)
>> +		return 0;
>> +
>> +	opt = kstrdup(options, GFP_KERNEL);
>> +	if (!opt)
>> +		return 1;
>> +	
>> +	ret = 1;
>> +
>> +	start = opt;
>> +	while ((p = strsep(&opt, ",")) != NULL) {
>> +		int token;
>> +		if (!*p)
>> +			continue;
>> +
>> +		/*
>> +		 * Initialize args struct so we know whether arg was
>> +		 * found; some options take optional arguments.
>> +		 */
>> +		args[0].to = args[0].from = 0;
>> +		token = match_token(p, tokens, args);
>> +		switch (token) {
>> +		case 1:
>> +			if (!args[0].from)
>> +				break;
>> +
>> +			if (match_int(&args[0],&option))
>> +				break;
>
> What if there are 2 passed options and the second fails?
>
>     mount -o vfs_dcache_size=XXX,vfs_dcache_size=CRAP<dev>  <mntpoint>
>
> In this case you leave the second option and pass it to the fs option
> parser (as you already set ret=0), which is wrong.  I think you should
> explicitly return 1 where you know the option is related to VFS, but you
> failed to parse it.  It would look even simplier than current code.

Good point, thank you. I agree.

> (Yes, this is a rare situation, but I can imagine some program that
> automatically adds mount options to the existing list and passes it to
> mount.)
>
Absolutely.

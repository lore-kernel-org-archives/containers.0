From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [RFC][PATCH 3/4] checkpoint/restart: memory management
Date: Fri, 8 Aug 2008 14:12:17 +0200
Message-ID: <200808081412.18268.arnd@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <20080807224037.44DA0DB8@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080807224037.44DA0DB8@kernel>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Friday 08 August 2008, Dave Hansen wrote:
> 
> diff -puN ckpt/ckpt_hdr.h~memory_part ckpt/ckpt_hdr.h
> --- linux-2.6.git/ckpt/ckpt_hdr.h~memory_part	2008-08-05 08:37:29.000000000 -0700
> +++ linux-2.6.git-dave/ckpt/ckpt_hdr.h	2008-08-05 08:37:29.000000000 -0700
> @@ -67,3 +67,24 @@ struct cr_hdr_task {
>  };
>  
>  
> +
> +struct cr_hdr_mm {
> +	__u32 tag;	/* sharing identifier */
> +	__u64 start_code, end_code, start_data, end_data;
> +	__u64 start_brk, brk, start_stack;
> +	__u64 arg_start, arg_end, env_start, env_end;
> +	__s16 map_count;
> +};

Another structure that is not 32/64 bit ABI safe on x86. It would be safe
if you reorder the members as

struct cr_hdr_mm {
	__u32 tag;	/* sharing identifier */
	__s16 map_count;
	__u16 pad; /* not actually needed, but better to make it explicit */
	__u64 start_code, end_code, start_data, end_data;
	__u64 start_brk, brk, start_stack;
	__u64 arg_start, arg_end, env_start, env_end;
};

> +struct cr_hdr_vma {
> +	__u32 how;
> +
> +	__u64 vm_start;
> +	__u64 vm_end;
> +	__u64 vm_page_prot;
> +	__u64 vm_flags;
> +	__u64 vm_pgoff;
> +
> +	__s16 npages;
> +	__s16 namelen;
> +};

same here.


	Arnd <><

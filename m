From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 15:20:16 +0200
Message-ID: <1273756816.5605.3547.camel__36713.8724810959$1273756958$gmane$org@twins>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273744285-8128-1-git-send-email-xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>, Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2010-05-13 at 17:51 +0800, Changli Gao wrote:
> +void *__kvmalloc(size_t size, gfp_t flags)
> +{
> +       void *ptr;
> +
> +       if (size < PAGE_SIZE)
> +               return kmalloc(size, GFP_KERNEL | flags);
> +       size = PAGE_ALIGN(size);
> +       if (is_power_of_2(size))
> +               ptr = (void *)__get_free_pages(GFP_KERNEL | flags |
> +                                              __GFP_NOWARN, get_order(size));
> +       else
> +               ptr = alloc_pages_exact(size, GFP_KERNEL | flags |
> +                                             __GFP_NOWARN);
> +       if (ptr != NULL) {
> +               virt_to_head_page(ptr)->private = size;
> +               return ptr;
> +       }
> +
> +       ptr = vmalloc(size);
> +       if (ptr != NULL && (flags & __GFP_ZERO))
> +               memset(ptr, 0, size);
> +
> +       return ptr;
> +}
> +EXPORT_SYMBOL(__kvmalloc);

So if I do kvmalloc(size, GFP_ATOMIC) I get GFP_KERNEL|GFP_ATOMIC, which
is not a recommended variation because one should not mix __GFP_WAIT and
__GFP_HIGH.

So I would simply drop the gfp argument to avoid confusion.

> +void __kvfree(void *ptr, bool inatomic)
> +{
> +       if (unlikely(ZERO_OR_NULL_PTR(ptr)))
> +               return;
> +       if (is_vmalloc_addr(ptr)) {
> +               if (inatomic) {
> +                       struct work_struct *work;
> +
> +                       work = ptr;
> +                       BUILD_BUG_ON(sizeof(struct work_struct) > PAGE_SIZE);
> +                       INIT_WORK(work, kvfree_work);
> +                       schedule_work(work);
> +               } else {
> +                       vfree(ptr);
> +               }
> +       } else {
> +               struct page *page;
> +
> +               page = virt_to_head_page(ptr);
> +               if (PageSlab(page) || PageCompound(page))
> +                       kfree(ptr);
> +               else if (is_power_of_2(page->private))
> +                       free_pages((unsigned long)ptr,
> +                                  get_order(page->private));
> +               else
> +                       free_pages_exact(ptr, page->private);
> +       }
> +}
> +EXPORT_SYMBOL(__kvfree); 

NAK, I really utterly dislike that inatomic argument. The alloc side
doesn't function in atomic context either. Please keep the thing
symmetric in that regards.

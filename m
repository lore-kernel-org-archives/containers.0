From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][-mm PATCH 4/8] Memory controller memory accounting (v3)
Date: Fri, 20 Jul 2007 14:03:36 -0700
Message-ID: <6599ad830707201403n6a364514y601996145fa3714c@mail.gmail.com>
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	<20070720082440.20752.67223.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070720082440.20752.67223.sendpatchset@balbir-laptop>
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
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Eric W Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 7/20/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> +void __always_inline unlock_meta_page(struct page *page)
> +{
> +       bit_spin_unlock(PG_metapage, &page->flags);
> +}

Maybe add a BUG_ON(!test_bit(PG_metapage, &page->flags)) at least for
development?

> +       mem = rcu_dereference(mm->mem_container);
> +       /*
> +        * For every charge from the container, increment reference
> +        * count
> +        */
> +       css_get(&mem->css);
> +       rcu_read_unlock();

It's not clear to me that this is safe.

If

> +
> +       /*
> +        * If we created the meta_page, we should free it on exceeding
> +        * the container limit.
> +        */
> +       if (res_counter_charge(&mem->res, 1)) {
> +               css_put(&mem->css);
> +               goto free_mp;
> +       }
> +
> +       lock_meta_page(page);
> +       /*
> +        * Check if somebody else beat us to allocating the meta_page
> +        */
> +       if (page_get_meta_page(page)) {

I think you need to add something like

  kfree(mp);
  mp = page_get_meta_page(page);

otherwise you're going to leak the new but unneeded metapage.

> +               atomic_inc(&mp->ref_cnt);
> +               res_counter_uncharge(&mem->res, 1);
> +               goto done;
> +       }
> +
> +       atomic_set(&mp->ref_cnt, 1);
> +       mp->mem_container = mem;
> +       mp->page = page;
> +       page_assign_meta_page(page, mp);

Would it make sense to have the "mp->page = page" be part of
page_assign_meta_page() for consistency?

> +err:
> +       unlock_meta_page(page);
> +       return -ENOMEM;

The only jump to err: is from a location where the metapage is already
unlocked. Maybe scrap err: and just do a return -ENOMEM when the
allocation fails?

> +out_uncharge:
> +       mem_container_uncharge(page_get_meta_page(page));

Wanting to call mem_container_uncharge() on a page and hence having to
call page_get_meta_page() seems to be more common than wanting to call
it on a meta page that you already have available. Maybe make
mem_container_uncharge() be a wrapper that take a struct page and does
something like mem_container_uncharge_mp(page_get_meta_page(page))
where mem_container_uncharge_mp() is the raw meta-page version?

Paul

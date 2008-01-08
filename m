From: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/4] Some changes in the kobject mapper
Date: Tue, 08 Jan 2008 19:36:36 +0100
Message-ID: <4783C2B4.7000501@hozac.com>
References: <47833C3A.8090106@openvz.org> <47833D43.3090703@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47833D43.3090703-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> The main thing that I want from the kobj mapper is to add 
> the mode_t on the struct kobj_map that reflects with 
> permissions are associated with this particular map. This 
> mode is to be returned via the kobj_lookup.
> 
> I use the FMODE_XXX flags to handle the permissions bits, 
> as I will compare these ones to the file->f_mode later.
> By default all bits are set (for the initial container).
> 
> The additional things I need are kobj_remap() to change 
> that permission and kobj_iterate() to walk the map.
> 
> The kobj_map_fini() is the roll-back for the kobj_map_init().
> 
> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> ...
> @@ -153,3 +237,21 @@ struct kobj_map *kobj_map_init(kobj_probe_t *base_probe, struct mutex *lock)
>  	p->lock = lock;
>  	return p;
>  }
> +
> +void kobj_map_fini(struct kobj_map *map)
> +{
> +	int i;
> +	struct probe *p, *next;
> +
> +	for (i = 0; i < 256; i++) {

This should be 255, shouldn't it?

> +		p = map->probes[i];
> +		while (p->next != NULL) {
> +			next = p->next;
> +			kfree(p);
> +			p = next;
> +		}
> +	}
> +
> +	kfree(p);
> +	kfree(map);
> +}
> diff --git a/include/linux/kobj_map.h b/include/linux/kobj_map.h
> index bafe178..ecfe772 100644
> --- a/include/linux/kobj_map.h
> +++ b/include/linux/kobj_map.h
> @@ -7,8 +7,13 @@ struct kobj_map;
>  
>  int kobj_map(struct kobj_map *, dev_t, unsigned long, struct module *,
>  	     kobj_probe_t *, int (*)(dev_t, void *), void *);
> +int kobj_remap(struct kobj_map *, dev_t, mode_t, unsigned long, struct module *,
> +	     kobj_probe_t *, int (*)(dev_t, void *), void *);
>  void kobj_unmap(struct kobj_map *, dev_t, unsigned long);
> -struct kobject *kobj_lookup(struct kobj_map *, dev_t, int *);
> +struct kobject *kobj_lookup(struct kobj_map *, dev_t, mode_t *, int *);
> +void kobj_map_iterate(struct kobj_map *, int (*fn)(dev_t, int, mode_t, void *),
> +		void *);
>  struct kobj_map *kobj_map_init(kobj_probe_t *, struct mutex *);
> +void kobj_map_fini(struct kobj_map *);
>  
>  #endif
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers


-- 
Daniel Hokka Zakrisson

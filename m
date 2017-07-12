From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Tue, 11 Jul 2017 22:45:03 -0500
Message-ID: <20170712034503.GA8270__25386.2345628024$1499831116$gmane$org@mail.hallyn.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499785511-17192-2-git-send-email-stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Stefan Berger (Stefan Bergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> +/*
> + * xattr_list_userns_rewrite - Rewrite list of xattr names for user namespaces
> + *                             or determine needed size for attribute list
> + *                             in case size == 0
> + *
> + * In a user namespace we do not present all extended attributes to the
> + * user. We filter out those that are in the list of userns supported xattr.
> + * Besides that we filter out those with @uid=<uid> when there is no mapping
> + * for that uid in the current user namespace.
> + *
> + * @list:        list of 0-byte separated xattr names
> + * @size:        the size of the list; may be 0 to determine needed list size
> + * @list_maxlen: allocated buffer size of list
> + */
> +static ssize_t
> +xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
> +{
> +	char *nlist = NULL;
> +	size_t s_off, len, nlen;
> +	ssize_t d_off;
> +	char *name, *newname;
> +
> +	if (!list || size < 0 || current_user_ns() == &init_user_ns)
> +		return size;
> +
> +	if (size) {
> +		nlist = kmalloc(list_maxlen, GFP_KERNEL);
> +		if (!nlist)
> +			return -ENOMEM;
> +	}
> +
> +	s_off = d_off = 0;
> +	while (s_off < size || size == 0) {
> +		name = &list[s_off];
> +
> +		len = strlen(name);
> +		if (!len)
> +			break;
> +
> +		if (xattr_is_userns_supported(name, false) >= 0)
> +			newname = name;
> +		else {
> +			newname = xattr_rewrite_userns_xattr(name);

Why are you doing this here?  If we get here it means that
xattr_is_userns_supported() returned < 0, meaning name is
not userns-supported.  So xattr_rewrite_userns_xattr() will
just return name.  Am I missing something?

> +			if (IS_ERR(newname)) {
> +				d_off = PTR_ERR(newname);
> +				goto out_free;
> +			}
> +		}
> +		if (newname && !xattr_list_contains(nlist, d_off, newname)) {

Now here, if name was recalculated to @newname, and @newname is
found in the nlist, that should raise an error right?  Something
fishy is going on?

> +			nlen = strlen(newname);
> +
> +			if (nlist) {
> +				if (nlen + 1 > list_maxlen)

d_off needs to be set to -ERANGE here.

> +					break;
> +				strcpy(&nlist[d_off], newname);
> +			}
> +
> +			d_off += nlen + 1;
> +			if (newname != name)
> +				kfree(newname);
> +		}
> +		s_off += len + 1;
> +	}
> +	if (nlist)
> +		memcpy(list, nlist, d_off);
> +out_free:
> +	kfree(nlist);
> +
> +	return d_off;
> +}

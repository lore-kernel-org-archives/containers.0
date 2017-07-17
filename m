From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Mon, 17 Jul 2017 14:58:11 -0400
Message-ID: <20170717185811.GC15794@redhat.com>
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
To: Stefan Berger <StefanBergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 11, 2017 at 11:05:11AM -0400, Stefan Berger wrote:

[..]
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

size will never be less than 0 here. Only caller calls this function only
if size is >0. So can we remove this?

What about case of "!list". So if user space called listxattr(foo, NULL,
0), we want to return the size of buffer as if all the xattrs will be
returned to user space. But in practice we probably will filter out some
xattrs so actually returned string will be smaller than size reported
previously.

Looks like that's the intent of "!list" condition here. Just wanted to
make sure, hence asking.

BTW, I am testing this with overlayfs and trying to figure out if
switching of creds will create issues. Simple operations like listxattr
and getxattr and setxattr so far worked for me. And reason seems to be
that name transformation we are doing in top layer based on creds of
caller (and not based on creds of mounter). 

Vivek

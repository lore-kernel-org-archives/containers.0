From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Tue, 18 Jul 2017 08:36:03 -0400
Message-ID: <20170718123603.GC8233__3640.1383382783$1500381374$gmane$org@redhat.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<20170717185811.GC15794@redhat.com>
	<7a39e8a6-a33b-f6a8-3fd5-6211c075ab91@linux.vnet.ibm.com>
	<20170718114849.GA8233@redhat.com>
	<55971eea-fde2-439a-2fe5-d0ae5e80bc22@linux.vnet.ibm.com>
	<20170718123009.GB8233@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170718123009.GB8233-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, Stefan Berger <StefanBergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 18, 2017 at 08:30:09AM -0400, Vivek Goyal wrote:
> On Tue, Jul 18, 2017 at 08:05:18AM -0400, Stefan Berger wrote:
> > On 07/18/2017 07:48 AM, Vivek Goyal wrote:
> > > On Mon, Jul 17, 2017 at 04:50:22PM -0400, Stefan Berger wrote:
> > > > On 07/17/2017 02:58 PM, Vivek Goyal wrote:
> > > > > On Tue, Jul 11, 2017 at 11:05:11AM -0400, Stefan Berger wrote:
> > > > > 
> > > > > [..]
> > > > > > +/*
> > > > > > + * xattr_list_userns_rewrite - Rewrite list of xattr names for user namespaces
> > > > > > + *                             or determine needed size for attribute list
> > > > > > + *                             in case size == 0
> > > > > > + *
> > > > > > + * In a user namespace we do not present all extended attributes to the
> > > > > > + * user. We filter out those that are in the list of userns supported xattr.
> > > > > > + * Besides that we filter out those with @uid=<uid> when there is no mapping
> > > > > > + * for that uid in the current user namespace.
> > > > > > + *
> > > > > > + * @list:        list of 0-byte separated xattr names
> > > > > > + * @size:        the size of the list; may be 0 to determine needed list size
> > > > > > + * @list_maxlen: allocated buffer size of list
> > > > > > + */
> > > > > > +static ssize_t
> > > > > > +xattr_list_userns_rewrite(char *list, ssize_t size, size_t list_maxlen)
> > > > > > +{
> > > > > > +	char *nlist = NULL;
> > > > > > +	size_t s_off, len, nlen;
> > > > > > +	ssize_t d_off;
> > > > > > +	char *name, *newname;
> > > > > > +
> > > > > > +	if (!list || size < 0 || current_user_ns() == &init_user_ns)
> > > > > size will never be less than 0 here. Only caller calls this function only
> > > > > if size is >0. So can we remove this?
> > > > Correct.
> > > > 
> > > > > What about case of "!list". So if user space called listxattr(foo, NULL,
> > > > > 0), we want to return the size of buffer as if all the xattrs will be
> > > > > returned to user space. But in practice we probably will filter out some
> > > > > xattrs so actually returned string will be smaller than size reported
> > > > > previously.
> > > > This case of size=0 is a problem in userns. Depending on the mapping of the
> > > > userid's the list can expand. A security.foo@uid=100 can become
> > > > security.foo@uid=100000, if the mapping is set up so that uid 100 on the
> > > > host becomes uid 100000 inside the container. So for now we only have
> > > > security.capability and the way I solved this is by allocating a 65k buffer
> > > > when calling from a userns. In this buffer where we gather the xattr names
> > > > and then walk them to determine the size that's needed for the buffer by
> > > > simulating the rewriting. It's not nice but I don't know of any other
> > > > solution.
> > > Hi Stefan,
> > > 
> > > For the case of size==0, why don't we iterate through all the xattr,
> > > filter them, remap them and then return the size to process in user
> > > namespace. That should fix this? I thought that's what
> > 
> > 
> > For the size==0 we need a temp. buffer where the raw xattr names are written
> > to so that the xattr_list_userns_rewrite() can actually rewrite what the
> > filesystem drivers returned.
> 
> I am probably missing something, but for the case of size==0, we don't
> have to copy all xattrs. We just need to determine size. So we can walk
> through each xattr, remap it and add to the size. I mean there should not
> be a need to allocate this 65K buffer. Just enough space needed to be
> able to store remapped xattr.
> 
> You are already doing it in xattr_parse_uid_from_kuid(). It returns the
> buffer containing remapped xattr. So we should be able to just determine
> the size and free the buffer. And do it for all the xattrs returned by
> filesystem.
> 
> What am I missing?

Oh, I think I get it. If I don't pass a buffer to underlying driver, then
it will just return the size (and not actual list). So that's why you are
allocating that big buffer and getting the whole list internally, doing
mapping and returning size to user space. Hmm...

Vivek

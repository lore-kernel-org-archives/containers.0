From: Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: Re: [PATCH 08/11] fuse: Support fuse filesystems outside of
	init_user_ns
Date: Thu, 18 Jan 2018 11:29:29 +0100
Message-ID: <CADZs7q45--wKbWmuANHfTHbMYo1thQgtZ1u1Yg3LWpU4BNd-TQ__42944.1754393794$1516271276$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<c85c293e19a478353aba8e6e3ee39e5914f798d5.1512041070.git.dongsu@kinvolk.io>
	<CADZs7q5NA7Kox62vnCOkL=TGgzTxX+oNYz6=oNXKWkQkQwSMrA@mail.gmail.com>
	<20180117142935.GA3723@ubuntu-xps13>
	<CADZs7q6ZHGHbrdL96Bmy148Zc6TxruiJrEeDjaDYEX8U-5QV1A@mail.gmail.com>
	<20180117193124.GC3723@ubuntu-xps13>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180117193124.GC3723@ubuntu-xps13>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 17, 2018 at 8:31 PM, Seth Forshee
<seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> On Wed, Jan 17, 2018 at 07:56:59PM +0100, Alban Crequy wrote:
>> On Wed, Jan 17, 2018 at 3:29 PM, Seth Forshee
>> <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
>> > On Wed, Jan 17, 2018 at 11:59:06AM +0100, Alban Crequy wrote:
>> >> [Adding Tejun, David, Tom for question about cuse]
>> >>
>> >> On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
>> >> > From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> >> >
>> >> > In order to support mounts from namespaces other than
>> >> > init_user_ns, fuse must translate uids and gids to/from the
>> >> > userns of the process servicing requests on /dev/fuse. This
>> >> > patch does that, with a couple of restrictions on the namespace:
>> >> >
>> >> >  - The userns for the fuse connection is fixed to the namespace
>> >> >    from which /dev/fuse is opened.
>> >> >
>> >> >  - The namespace must be the same as s_user_ns.
>> >> >
>> >> > These restrictions simplify the implementation by avoiding the
>> >> > need to pass around userns references and by allowing fuse to
>> >> > rely on the checks in inode_change_ok for ownership changes.
>> >> > Either restriction could be relaxed in the future if needed.
>> >> >
>> >> > For cuse the namespace used for the connection is also simply
>> >> > current_user_ns() at the time /dev/cuse is opened.
>> >>
>> >> Was a use case discussed for using cuse in a new unprivileged userns?
>> >>
>> >> I ran some tests yesterday with cusexmp [1] and I could add a new char
>> >> device as an unprivileged user with:
>> >>
>> >> $ unshare -U -r -m sh -c 'mount --bind /mnt/cuse /dev/cuse ; cusexmp
>> >> --maj=99 --min=30 --name=foo
>> >>
>> >> where /mnt/cuse is previously mknod'ed correctly and chmod'ed 777.
>> >> Then, I could see the new device:
>> >>
>> >> $ cat /proc/devices | grep foo
>> >>  99 foo
>> >>
>> >> On normal distros, we don't have a /mnt/cuse chmod'ed 777 but still it
>> >> seems dangerous if the dev node can be provided otherwise and if we
>> >> don't have a use case for it.
>> >>
>> >> Thoughts?
>> >
>> > I can't remember the specific reasons, but I had concluded that letting
>> > unprivileged users use cuse within a user namespace isn't safe. But
>> > having a cuse device node usable by regular users at all is equally
>> > unsafe I suspect,
>>
>> This makes sense.
>>
>> > so I don't think your example demonstrates any problem
>> > specific to user namespaces. There shouldn't be any way to use a user
>> > namespace to gain access permissions towards /dev/cuse, otherwise we
>> > have bigger problems than cuse to worry about.
>>
>> From my tests, the patch seem safe but I don't fully understand why that is.
>>
>> I am not trying to gain more permissions towards /dev/cuse but to
>> create another cuse char file from within the unprivileged userns. I
>> tested the scenario by patching the memfs userspace FUSE driver to
>> generate the char device whenever the file is named "cuse" (turning
>> the regular file into a char device with the cuse major/minor behind
>> the scene):
>>
>> $ unshare -U -r -m
>> # memfs /mnt/memfs &
>> # ls -l /mnt/memfs
>> # echo -n > /mnt/memfs/cuse
>> -bash: /mnt/memfs/cuse: Input/output error
>> # ls -l /mnt/memfs/cuse
>> crwxrwxrwx. 1 root root 10, 203 Jan 17 18:24 /mnt/memfs/cuse
>> # cat /mnt/memfs/cuse
>> cat: /mnt/memfs/cuse: Permission denied
>>
>> But then, I could not use that char device, even though it seems to
>> have the correct major/minor and permissions. The kernel FUSE code
>> seems to call init_special_inode() to handle character devices. I
>> don't understand why it seems to be safe.
>
> Because for new mounts in non-init user namespaces alloc_super() sets
> SB_I_NODEV flag in s_iflags, which disallows opening device nodes in
> that filesystem.

I see. Thanks for the explanation!

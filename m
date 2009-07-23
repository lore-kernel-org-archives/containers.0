From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] Support named cgroups hierarchies
Date: Wed, 22 Jul 2009 23:27:23 -0700
Message-ID: <6599ad830907222327s31340956y9783db39d076520f__41556.4557574273$1248330478$gmane$org@mail.gmail.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
	<20090722195029.7481.94700.stgit@menage.mtv.corp.google.com>
	<4A68013A.2020302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A68013A.2020302-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 22, 2009 at 11:20 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> +The name should match [\w.-]+
>> +
>
> "[\w._-]+" ?
>
> But I double we need to check this.

\w includes '_'

>> =A0static int cgroup_set_super(struct super_block *sb, void *data)
>> =A0{
>> =A0 =A0 =A0 int ret;
>> - =A0 =A0 struct cgroupfs_root *root =3D data;
>> + =A0 =A0 struct cgroup_sb_opts *opts =3D data;
>> +
>> + =A0 =A0 /* If we don't have a new root, we can't set up a new sb */
>> + =A0 =A0 if (!opts->new_root)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>
> I think this should be BUG_ON(). If set_super() is called,
> we are allocating a new root, so opts->new_root won't be NULL.

Not true - if you try to mount a hierarchy by name, but with no
subsystem options, then we don't construct a new root, but we still
call sget(). If we find a superblock with the right name then we use
it, else sget() will allocate a new superblock and call
cgroup_set_super(), at which point we need to fail.

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct cgroupfs_root *new_root =3D cgroup_root=
_from_opts(&opts);
>
> Why not just declare new_root in the beginning of cgroup_get_sb()?

Because it's not needed for the entire scope of the function. Keeping
its scope as small as possible makes it clearer what it's being used
for.

Paul

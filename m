From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 31 Aug 2011 23:07:05 -0400
Message-ID: <CAGZ=bqLE8uJj+m-LZM1OX093M+0aE6+zxJF0o5DPHOnYX3iA5A@mail.gmail.com>
References: <20110831075814.003575573@openvz.org> <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros> <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name> <20110831142622.GB30615@sun> <20110831151023.5b7e12da.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110831151023.5b7e12da.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Wed, Aug 31, 2011 at 18:10, Andrew Morton <akpm@linux-foundation.org=
> wrote:
> On Wed, 31 Aug 2011 18:26:22 +0400  Cyrill Gorcunov <gorcunov@gmail.c=
om> wrote:
>> This one behaves similarly to the /proc/<pid>/fd/ one - it contains =
symlinks
>> one for each mapping with file, the name of a symlink is "vma->vm_st=
art-vma->vm_end",
>> the target is the file. Opening a symlink results in a file that poi=
nt exactly
>> to the same inode as them vma's one.
>>
>> For example the ls -l of some arbitrary /proc/<pid>/map_files/
>>
>> =C2=A0| lr-x------ 1 root root 64 Aug 26 06:40 7f8f80403000-7f8f8040=
4000 -> /lib64/libc-2.5.so
>> =C2=A0| lr-x------ 1 root root 64 Aug 26 06:40 7f8f8061e000-7f8f8062=
0000 -> /lib64/libselinux.so.1
>> =C2=A0| lr-x------ 1 root root 64 Aug 26 06:40 7f8f80826000-7f8f8082=
7000 -> /lib64/libacl.so.1.1.0
>> =C2=A0| lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a2f000-7f8f80a3=
0000 -> /lib64/librt-2.5.so
>> =C2=A0| lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a30000-7f8f80a4=
c000 -> /lib64/ld-2.5.so
>
> This particular patch introduces a distressing amount of duplication =
of
> /proc/pid/maps. =C2=A0The changelog should provide a really good
> justification for doing this: why is /proc/pid/maps (and smaps!)
> unsuitable and why cannot maps/smaps be fixed to be suitable?

Andrew,

This is way more useful than /proc/$PID/maps, because this allows you
to reliably obtain an FD to an arbitrary mapped memory segment.

EG:
  $ cp /bin/sleep ~/my-sleep
  $ ~/my-sleep 1000 & kid=3D$!
  $ rm ~/my-sleep
  $ mkdir ~/mapped_files
  $ for file in /proc/$kid/map_files/*; do cp "$file" ~/mapped_files/; =
done

This trivially gets me copies of every mapped file, including the delet=
ed
"my-sleep" binary, it also trivially handles lazy-unmounted filesystems=
,
chroots, namespaces, and all sorts of similar kernel cleverness.

It's exactly the same kind of utility that /proc/$PID/fd/* has, but for
mmap().

With /proc/$kid/maps you simply can't work around some of those
kinds of issues (IE: deleted files, etc).

Cheers,
Kyle Moffett
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

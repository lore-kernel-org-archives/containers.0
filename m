From: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Make Dynamic ELF binary loader settable.
Date: Wed, 6 Aug 2014 12:23:19 +1000
Message-ID: <CANA3KFW9GWo6Kd1stCQypV3XwoLjWi-RrQ6AaiVDjYK-WbmS5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Containers as used in docker give some application portability.

There is a universal headache in the room.    Dynamic ELF binaries
have a build into binary interpreter string.   Bad part is the dynamic
binary interpreter is part of the libc so you must have the right libc
and interpreter together or bad things can happen.

Ok patchelf is a option but its not a good one when you wake up that
you can no longer checksum your binary.    So you cannot do signed
binaries.

So the problem comes how to create a solution that will work and will
not cause a security mess.   What has come my mind is extended file
attributes(xattr) exist lets not make use of them.

I can get so far to creating a patch to fix this issue then I run into
a road block.

Yes I can find where the interpreter is read from the executable simple enough
In 2.16 Linux
fs/binfmt_elf.c line 655 as elf_interpreter
and
fs/binfmt_elf_fdpic.c line 216 as interpreter_name

Problem is I cannot find the other half I want.   How to lookup a
xattr in kernel space on the elf binary so allowing the interpreter to
be assigned from a xattr value if no xattr value do exactly what it
use to.   A small static binary for installers can set xattr option no
issues.  Its so annoying to be so close but so far from being able to
make a proto patch any clues about xattr look up.

This removes script wrapping and allows use of compatibility options.

Now if we can make this work.   This will allow kernel tools including
the ones to control containers to ship as distribution independent
binaries with bundled libc.

I can see debugging advantages.   Remember you cannot mix particular
licenses into a single binary either.   Yes that they can dynamic link
does not mean you can legally make a static binary of them.

If I can workout how to make kernel loader to xattr value the next
will be make ld-linux.so accept xattr options.   Like the orgin
problem with RPATH and LD_PRELOAD issue on Suid bit binaries heck
these days there are a lot of dbus using binaries where environmental
overrides of interpreter should fail since they are not directly
connected to the file.

Please pardon me posting this here.   I could not find a mailing list
that directly relates to messing with the loaders.

Peter Dolding

From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [TOOLS] To make use of the patches
Date: Sat, 23 Jul 2011 12:32:04 +0400
Message-ID: <4E2A8704.3030306@parallels.com>
References: <4E204466.8010204@parallels.com> <4E204554.6040901@parallels.com>
	<20110722234558.GD16940@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110722234558.GD16940-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

>> #define PIPEFS_MAGIC 0x50495045
> 
> Shouldn't there be only one MAGIC number for checkpoint contents?
> 
> You can always add an additional "type" number following the magic
> number. Or make the type a string with the name of the /proc file it's
> from... etc.

Don't get your idea here, can you elaborate please?

>> static void continue_task(int pid)
>> {
>>       if (kill(pid, SIGCONT))
>>               perror("Can't cont task");
>> }
> 
> Eventually, I think you should use the cgroup freezer here rather
> than signals. Shells and debuggers use these signals so a checkpoint
> could easily and quietly be corrupted.

Yes sure! As I told, I will switch to one in the 2nd iteration.

> Even if you use the freezer, there needs to be a mechanism to
> assure that the frozen cgroup is not thawed before a consistent
> checkpoint is complete. Otherwise corruption is always a possibility.

Yes, this is a good point. I'm thinking about it.

>> static int dump_pipe_and_data(int lfd, struct pipes_entry *e)
>> {
>>       int steal_pipe[2];
>>       int ret;
>>
>>       printf("\tDumping data from pipe %x\n", e->pipeid);
>>       if (pipe(steal_pipe) < 0) {
>>               perror("Can't create pipe for stealing data");
>>               return 1;
>>       }
>>
>>       ret = tee(lfd, steal_pipe[1], MAX_PIPE_BUF_SIZE, SPLICE_F_NONBLOCK);
> 
> Neat application of tee().

Thanks! :)

>>       if (ret < 0) {
>>               if (errno != EAGAIN) {
>>                       perror("Can't pick pipe data");
>>                       return 1;
>>               }
>>
>>               ret = 0;
>>       }
>>
>>       e->bytes = ret;
>>       write(pipes_img, e, sizeof(*e));
>>
>>       if (ret) {
>>               ret = splice(steal_pipe[0], NULL, pipes_img, NULL, ret, 0);
>>               if (ret < 0) {
>>                       perror("Can't push pipe data");
>>                       return 1;
>>               }
>>       }
>>
>>       close(steal_pipe[0]);
>>       close(steal_pipe[1]);
>>       return 0;
>> }
>>
>> static int dump_one_pipe(int fd, int lfd, unsigned int id, unsigned int flags)
>> {
>>       struct pipes_entry e;
>>
>>       printf("\tDumping pipe %d/%x flags %x\n", fd, id, flags);
>>
>>       e.fd = fd;
>>       e.pipeid = id;
>>       e.flags = flags;
>>
>>       if (flags & O_WRONLY) {
>>               e.bytes = 0;
>>               write(pipes_img, &e, sizeof(e));
>>               return 0;
>>       }
>>
>>       return dump_pipe_and_data(lfd, &e);
>> }
>>
>> static int dump_one_fd(int dir, char *fd_name, unsigned long pos, unsigned int flags)
>> {
>>       int fd;
>>       struct stat st_buf;
>>       struct statfs stfs_buf;
>>
>>       printf("\tDumping fd %s\n", fd_name);
>>       fd = openat(dir, fd_name, O_RDONLY);
>>       if (fd == -1) {
>>               printf("Tried to openat %d/%d %s\n", getpid(), dir, fd_name);
>>               perror("Can't open fd");
>>               return 1;
>>       }
>>
>>       if (fstat(fd, &st_buf) < 0) {
>>               perror("Can't stat one");
>>               return 1;
>>       }
>>
>>       if (S_ISREG(st_buf.st_mode))
>>               return dump_one_reg_file(FDINFO_FD, atoi(fd_name), fd, 1, pos, flags);
>>
>>       if (S_ISFIFO(st_buf.st_mode)) {
>>               if (fstatfs(fd, &stfs_buf) < 0) {
>>                       perror("Can't statfs one");
>>                       return 1;
>>               }
>>
>>               if (stfs_buf.f_type == PIPEFS_MAGIC)
>>                       return dump_one_pipe(atoi(fd_name), fd, st_buf.st_ino, flags);
>>       }
> 
> This is starting to look like a linear search over the set of all
> possible types of things file descriptors can refer to. A kernel implementation
> doesn't have to do this. Furthermore, if lots of file descriptors are open
> this could be alot of fstat() and fstatfs() calls -- will making so many
> syscalls force us to an completely in-kernel implementation, like the
> set already proposed, just to get usable performance?

A kernel implementation doesn't have to do any syscalls at all. If we're going to
do it in kernel, then we should throw this set away and resurrect the Oren's set.

As far as the many fstats is concerned - yes, some sort of optimization about this
is surely required.

>>
>>       if (!strcmp(fd_name, "0")) {
>>               printf("\tSkipping stdin\n");
>>               return 0;
>>       }
> 
> Assuming that fd 0 is "stdin" is very very gross. Yes, it's almost always
> true. But that does *not* mean that it's a pty. stdin could be a pipe
> we need to checkpoint. Really, this is also about the "type" of thing
> the fd is referring to -- not about which fd nr it is.
> 
> What are your plans for removing this?

This was done just to make it possible to demonstrate what this code can do
checkpointing shell scripts and restoring them in (probably) another session.

The plan for this part is - implement the c/r support for terminals and throw
this explicit check for stdio-s away :)

>> static unsigned long rawhex(char *str, char **end)
>> {
>>       unsigned long ret = 0;
>>
>>       while (1) {
>>               if (str[0] >= '0' && str[0] <= '9') {
>>                       ret <<= 4;
>>                       ret += str[0] - '0';
>>               } else if (str[0] >= 'a' && str[0] <= 'f') {
>>                       ret <<= 4;
>>                       ret += str[0] - 'a' + 0xA;
>>               } else if (str[0] >= 'A' && str[0] <= 'F') {
>>                       ret <<= 4;
>>                       ret += str[0] - 'A' + 0xA;
>>               } else {
>>                       if (end)
>>                               *end = str;
>>                       return ret;
>>               }
>>
>>               str++;
>>       }
>> }
> 
> nit: I haven't looked closely enough to see where rawhex is being used,
>         but is there's no suitable library function for this?

Well, I looked for but did found. All I've met required an 0x to precede the hex number.
If you point me one - I will gladly replace mine with it.

>> static int dump_file_shared_map(char *start, char *mdesc, int lfd)
>> {
>>       printf("\tSkipping file shared mapping at %s\n", start);
>>       close(lfd);
>>       return 0;
>> }
> 
> Shouldn't this be an error since it appears these shared mappings
> are currently unsupported?

Why unsupported? Shared file mappings are fully supported, unless some bug found its
way into the source.

>>       printf("%d/%d EXEC IMAGE\n", pid, getpid());
>>       return execl(path, path, NULL);
> 
> How are you going to restore O_CLOEXEC flags?

Don't know yet. But assuming we have agreed on using execve for restoring tasks, then the solution
is - just set this flag and call exec. Since my binary handler doesn't call the setup_new_exec
(which closes the files) these bits will be preserved


> For any subsequent postings could you split this up into multiple
> emails -- perhaps one per file? 

OK, will do this.

> Or perhaps make them patches to the kernel's tools directory?

Hm... I didn't think about having these tools be the part of the kernel source tree.

Maybe it would be better if I publish the tools in git repo, what do you think?

> Cheers,
>         -Matt Helsley
> .
> 

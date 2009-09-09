From: Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Understanding CPU containers
Date: Wed, 9 Sep 2009 16:00:27 +0530
Message-ID: <c7704c490909090330m494bc910n170f04c09cdeeeea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,
       I am trying to understand the behavior of CPU containers as I
am unable to explain few things.
- Built the latest kernel 2.6.30.5 and installed on my Intel core2Duo deskt=
op

- Mounted the cpu subsystem using

      - mount -t cgroup -ocpu cgroup /containers/cpu/

- Created 3 sub directories under /containers/cpu

        - 512 for cpu.shares=3D512

        - 1024 for cpu.shares=3D1024

        - 2048 for cpu.shares=3D2048

- Created 3 bash terminals and attached each one to the individual cpu
sub system using the /bin/echo command. This essentially allows any
process created by the shells to be automatically added to the cpu
subsystem to which the shell belongs

- Ran a compute intensive benchmark =93openssl speed aes-256-cbc=94
benchmark on all the shells at the same time.

- Enclosing the numbers from the run=85

    - Observed CPU Utilization : 99.8 , 49.9 , 49.9

Results from the run

The 'numbers' are in 1000s of bytes per second processed.

CPU shares allocation

                            16 bytes                     64 bytes
            256 bytes=A0=A0           1024 bytes=A0=A0           8192 bytes

512                        35459.95k=A0=A0=A0                43441.75k
          46660.35k=A0=A0=A0         46707.71k=A0=A0=A0           77040.30k

1024                      57448.63k                    44050.54k
          46558.98k            46633.03k              47252.76k

2048                    71186.36k                    87142.02k
        92513.79k            93769.05k              94795.09k

1024 vs 512          1.62                            1.01
            0.99                     0.99                      0.61

2048 vs 1024         1.23                           1.97
           1.98                      2.01                     2

Observations

        - Unless the cpu resources are overcommitted, there is no
value in the allocating shares to the containers.
        - 2048 vs 1024 cpu containers, the scale is 2X, except for 16 bytes
 =A0=A0=A0=A0=A0=A0=A0- 512 vs 1024 cpu containers, there is no difference =
at all,
except for 16 bytes
 =A0=A0=A0=A0=A0=A0=A0- 512 vs 1024 cpu containers, there is no difference =
for 8192
bytes as the remaining 2 openssl runs are complete.
 =A0=A0=A0=A0=A0=A0=A0- For CPU bound, there has to be an over commit on th=
e CPUs
otherwise the share allocation does not matter
        - One cannot dynamically assign cpus to the container, by
default, it runs on the no of cores available.

Any pointers are helpful

Thanks

Mukesh

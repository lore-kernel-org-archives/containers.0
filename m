From: Pankaj Charpe <pankaj.charpe-M94ZStPJgW9Wk0Htik3J/w@public.gmane.org>
Subject: Problem in Cross compiling
Date: Wed, 28 Dec 2016 11:09:46 +0530
Message-ID: <CAB29hWeXrEUM5+O8CJdU2iT0mzcuM1hw8jO__r_XMuREK0O2BQ@mail.gmail.com>
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

 I am cross compiling iproute2 for mipsel linux kernel but I am getting the
following error : Below are my stpes




*PATH=$PATH:/opt/buildroot-gcc463/usr/binexport
PATHSTAGING_DIR=/opt/buildroot-gcc463/usrexport STAGING_DIR*

*root@pankaj:/home/venkat/usb/iproute2-4.9.0# ./configure
--build=x86_64-unknown-linux-gnu -host=mipsel-linux*
TC schedulers
 ATM    no

libc has setns: yesyyyyyyyyyyyyyyyyyyyyyyyyyyy
SELinux support: no
ELF support: no
libmnl support: no
Berkeley DB: yes

docs: latex: no
 WARNING: no docs can be built from LaTeX files
 sgml2html: no
 WARNING: no HTML docs can be built from SGML


*root@pankaj:/home/venkat/usb/iproute2-4.9.0# make CC=mipsel-linux-gcc
LD=mipsel-linux-ld*

lib
make[1]: Nothing to be done for `all'.

ip
    LINK     ip
../lib/libutil.a(utils.o): In function `format_host_r':
utils.c:(.text+0x21b8): warning: gethostbyaddr is obsolescent, use
getaddrinfo() instead.
../lib/libutil.a(namespace.o): In function `netns_switch':
namespace.c:(.text+0x84): undefined reference to `setns'
namespace.c:(.text+0x8c): undefined reference to `setns'
collect2: ld returned 1 exit status
make[1]: *** [ip] Error 1
make: *** [all] Error 2

Thanks & Regards
Pankaj Charpe

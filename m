From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: dm-ioband RPM packages
Date: Fri, 03 Apr 2009 20:04:04 +0900 (JST)
Message-ID: <20090403.200404.112612279.ryov__49335.9014777981$1238756953$gmane$org@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

This is a good news for LVM users, especially for RHEL and CentOS
users. You can control I/O bandwidth of your disks easily without
hassle, because I've made RPM binary packages of dm-ioband and
dm-ioband-config available at
  http://people.valinux.co.jp/~ryov/dm-ioband/binary.html

The RPM binary packages are for Red Hat Enterprise Linux 5.x and
CentOS 5.x. They were tested on CentOS 5.3 and will also work on other
5.x versions.

Please refer to the on-line manual at
  http://people.valinux.co.jp/~ryov/dm-ioband/manual/index.html
or the README file which is installed into
  /usr/share/doc/dm-ioband-VERSION
for usage information. 

The dm-ioband-config package provides a configuration file and an init
script to make it easy to assign bandwidth to LVM logical volumes. The
merits of using this are the followings:

  - I'm sure you can use this script without any efforts since most of
    modern Linux distributions already make filesystems on LVM logical
    volumes.
  - You can enable and disable dm-ioband anytime you want. No need to
    modify any configuration files which refer to the logical volumes,
    because enabling/disabling dm-ioband doesn't make any changes to
    device names and numbers.
  - You can apply dm-ioband to a root device even if it is already
    mounted.

The following diagram shows how dm-ioband is applied to the existing
logical volumes.

                          run "service ioband start"
                                    ===>
   -------------------------------       -------------------------------    
  |   LogVol00    |    LogVol01   |     |   LogVol00    |    LogVol01   |     
  |  (dm-linear)  |  (dm-linear)  |     |  (dm-ioband)  |  (dm-ioband)  | 
  |-------------------------------|     |-------------------------------|
  |           VolGroup00          |     | LogVol00-orig | LogVol01-orig |
   -------------------------------      |  (dm-linear)  |  (dm-linear)  |
                                        |-------------------------------|
                                        |          VolGroup00           |
                                         -------------------------------
                                    <===
                          run "service ioband stop"

Thanks for the device mapper infrastructure, any device mapper modules
can be dynamically pushed into kernel or replaced with other modules
anytime.

Please refer to the README file at
  http://people.valinux.co.jp/~ryov/dm-ioband-config/README.txt
or which is installed into
  /usr/share/doc/dm-ioband-config-VERSION
for usage information. 

Any comments and suggestions are welcome!

Thanks,
Ryo Tsuruta

dm-ioband is an IO controller which provides disk bandwidth control to
Linux. It can controls bandwidth on a per partition, per user, per
process basis and so on. If you use dm-ioband in a virtual machine
environment, you can control bandwidth on a per virtual machine basis.

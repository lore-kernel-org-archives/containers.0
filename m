From: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: RFC: Device Namespaces
Date: Thu, 22 Aug 2013 13:43:06 -0400
Message-ID: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi everyone!

We [1] have been working on bringing lightweight virtualization to
Linux-based mobile devices like Android (or other Linux-based devices with
diverse I/O) and want to share our solution: device namespaces.

Imagine you could run several instances of your favorite mobile OS or other
distributions in isolated containers, each under the impression of having
exclusive access to device drivers; Interact and switch between them within
a blink, no flashing, no reboot.

Device namespaces are an extension to existing Linux kernel namespaces that
brings lightweight virtualization to Linux-based end-user devices,
primarily mobile devices.
Device namespaces introduce a private and virtual namespace for device
drivers to create the illusion for a process group that it interacts
exclusively with a set of drivers. Device namespaces also introduce the
concepts of an =93active=94 namespace with which a user interacts, vs
=93non-active=94 namespaces that run in the background, and the ability to
switch between them.[2]

We are planning to prepare individual patches to be submitted to the
relevant maintainers and mailing lists. In the meantime, we already want to
share a set of patches on top of the Android goldfish Kernel 3.4 as well as
a user-space demo, so you can see where we are heading and get an overview
of the approach and see how it works.

We are aware that the patches are not ready for submission in their current
state, and we'd highly appreciate any feedback or suggestions which may
come to your mind once you have a look [3]. Of particular interest is to
elaborate a proper userspace API with respect to existing and future
use-cases. To illustrate a simple use-case we also provide a simple
userspace demo for Android [4].

I will be presenting "The Case for Linux Device Namespace" [5] at LinuxCon
North America 2013 [6]. We will also be attending the Containers Track [7]
at LPC 2013 to present the current state of the patches and discuss the
best course to proceed.

We are looking forward to hear from you!

Thanks,

Oren.


1: http://www.cellrox.com/
2: https://github.com/Cellrox/devns-patches/wiki/DeviceNamespace
3: https://github.com/Cellrox/devns-patches
4: https://github.com/Cellrox/devns-demo
5: http://sched.co/1asN1v7
6: http://events.linuxfoundation.org/events/linuxcon-north-america
7: http://www.linuxplumbersconf.org/2013/ocw/events/LPC2013/tracks/153

-- =

 Oren Laadan
 Cellrox Ltd.

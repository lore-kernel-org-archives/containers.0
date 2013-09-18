From: "Jeremy C. Andrus" <jeremya-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Cells open source release
Date: Wed, 18 Sep 2013 19:01:55 -0400
Message-ID: <0A81EE70-DDAB-4B46-8CB7-382299993360@cs.columbia.edu>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
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
To: containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
List-Id: containers.vger.kernel.org

Hello everyone,

On behalf of myself and the rest of the Cells team here at Columbia
University, I would like to announce the release of the Cells open
source project:
 info: http://cells.cs.columbia.edu/
 code: https://cells-source.cs.columbia.edu/

Cells provides multiple, isolated, virtual Android instances runnning
on a single device with support for smartphone and tablet hardware
including 3D graphics, WiFi, touchscreen input, and more. This release
targets the ASUS Nexus 7 (grouper) tablet, and supports essential
Android drivers and subsystems such as Android alarms, frame buffer
earlysuspend, wakelocks (suspend blockers), binder, and logger.

Users can create, modify, delete, start, and stop instances of Android
(Cells) using a command-line tool called "cell" through the standard
Android adb shell. Users can switch between instances of Android using
a key combo on their device (volume up + volume down on the Nexus 7),
or through the cell command.

We achieve all this by leveraging containers and namespaces in the
kernel, and by building on recently released kernel patches to support
device namespaces: https://github.com/Cellrox/devns-patches

Cells is minimally intrusive to the Android open-source project (AOSP)
code base with our Nexus 7 prototype requiring only a few small patches
to the Jelly Bean 4.3 repositories. A list of patches applied on top of both
AOSP, and the Nexus 7 Tegra kernel can be seen using a search on the
Cells Gerrit Review site:
https://cells-source.cs.columbia.edu/#/q/status:merged+topic:cells-nexus7,n,z

We invite anyone interested to download, build, and play with Cells.
We provide a guide on how to download, build, and contribute to the
sources here:
 http://cells.cs.columbia.edu/build/

We invite you to join the project mailing list and encourage you to ask
questions and discuss the sources on the list:
 cells-FPEHb7Xf0XXUo1n7N8X6UoWGPAHP3yOg@public.gmane.org
 https://lists.cs.columbia.edu/cucslists/listinfo/cells

Best Regards,

      -Jeremy

-- 
Cells: A Virtual Mobile Smartphone Architecture
Proceedings of the 23rd ACM Symposium on Operating Systems Principles (SOSP 2011)
[pdf]: http://systems.cs.columbia.edu/files/wpid-cells-sosp2011.pdf

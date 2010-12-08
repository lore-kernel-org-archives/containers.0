From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Containers HOWTO?  (Where do I start?)
Date: Wed, 8 Dec 2010 08:36:05 +0000
Message-ID: <7E28E74ACE78074AAD1BDD3E455CF87493D3@US-EXCH1.sw.swsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

I've been poking at the container code and reading the openvz wiki and the pages linked from http://lxc.sourceforge.net/index.php/about/kernel-namespaces/ and random other things Google finds like http://www.howtoforge.com/how-to-do-live-migration-of-openvz-containers but I have yet to find a good "start here" document for what I want to do.

I want to build a containers test environment from source.  I.E. I want to configure and build a kernel, build and configure my own root filesystem, invoke a chroot-with-benefits binary to set up a new init process in a container, and run test programs in the container.

I've found a lot of articles on how to use a distro to automate away the details, and I've found articles on several of the individual components, but if there's a design overview or a HOWTO on adding container support to a system you built yourself, I haven't found it yet.  (A case insensitive search of Documentation didn't find a filename with "contain" or "vz" in it.)

I have no shortage of things to read, but it's all really unfocused.  Any hints to help narrow my search?

Thanks,

Rob

From: Jeremias Blendin <jeremias-ZqkW+k4+4H9AfugRpC6u6w@public.gmane.org>
Subject: Get statistics from all network interfaces on a system, including
	those inside network namespaces
Date: Thu, 19 Mar 2015 14:22:21 +0100
Message-ID: <CAFZrTr52ksuMaJKbNGmQ3NuNLjRe8T15gaDvxuJ66errGN7g3g@mail.gmail.com>
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

Hi,

I hope this is the right list to post this question.

Currently, we are using a patched version of bwm-ng to poll statistics
of network interfaces. Some of these interfaces are located inside
network namespaces, unfortunately we have found no way to poll all
interfaces from all netspaces at once, without making our client
application process traverse through all the available network
namespaces (one result is this patch for bwm-ng:
https://github.com/jgjl/bwm-ng/tree/lxns).
Is there a more efficient way (for example by using netlink directly)
to get a complete list of the statistics of all network interfaces
existing in the kernel e.g. tagged by their netns?

Any pointers are appreciated :)

Best

Jeremias

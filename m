From: Mathieu Peresse <mathieu.peresse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: VRF-like use of Network Namespaces
Date: Tue, 8 Jun 2010 17:23:10 +0200
Message-ID: <AANLkTimA_0aZwZM1uZ-GH3OxfEZvegoitaaKTYPLvW5F@mail.gmail.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

I saw this post from Oct 2008:
https://lists.linux-foundation.org/pipermail/containers/2008-October/013917.html,
discussing how to manipulate network namespaces like we do with VRFs
on
Cisco routers (e.g. using normal network commands, plus appending "vrf
vrf_name" at the end to manipulate the desired VRF), without the need to
have processes "bound" to network namespaces.

Are there any activities on this subject ?

Thanks,

-- 
a+
mathieu

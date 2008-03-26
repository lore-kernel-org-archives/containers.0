From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] [2/2] Simple stats for memory resource controller
Date: Wed, 26 Mar 2008 11:52:21 -0700
Message-ID: <6599ad830803261152j1973e3c8oa82181a830f89260@mail.gmail.com>
References: <200803262348.59785.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761984AbYCZSwk@vger.kernel.org>
In-Reply-To: <200803262348.59785.balajirrao@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balaji Rao <balajirrao@gmail.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, balbir@in.ibm.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Wed, Mar 26, 2008 at 11:18 AM, Balaji Rao <balajirrao@gmail.com> wrote:
>         [MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
>  +       [MEM_CGROUP_STAT_PGIN_COUNT] = {"page_in_count", 1, },
>  +       [MEM_CGROUP_STAT_PGOUT_COUNT] = {"page_out_count", 1, },
>   };
>

Should these be called "pgpgin" and "pgpgout" for consistency with /proc/vmstat?

Paul
